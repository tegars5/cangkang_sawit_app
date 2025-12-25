# Orders Feature - Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER (UI)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │ OrderListPage   │  │OrderDetailPage  │  │CreateOrderPage  │            │
│  │                 │  │                 │  │                 │            │
│  │ - List orders   │  │ - Show details  │  │ - Form inputs   │            │
│  │ - Filter status │  │ - Action buttons│  │ - Validation    │            │
│  │ - Pull refresh  │  │ - Status display│  │ - Submit order  │            │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘            │
│           │                    │                     │                      │
│           └────────────────────┼─────────────────────┘                      │
│                                │                                            │
│                     ┌──────────▼─────────┐                                  │
│                     │  OrderNotifier     │                                  │
│                     │  (StateNotifier)   │                                  │
│                     │                    │                                  │
│                     │  - loadOrders()    │                                  │
│                     │  - loadOrderById() │                                  │
│                     │  - createOrder()   │                                  │
│                     │  - confirmOrder()  │                                  │
│                     │  - cancelOrder()   │                                  │
│                     │  - updateStatus()  │                                  │
│                     └──────────┬─────────┘                                  │
│                                │                                            │
│                     ┌──────────▼─────────┐                                  │
│                     │   OrderState       │                                  │
│                     │                    │                                  │
│                     │  - orders          │                                  │
│                     │  - selectedOrder   │                                  │
│                     │  - isLoading       │                                  │
│                     │  - errorMessage    │                                  │
│                     └────────────────────┘                                  │
│                                                                               │
└───────────────────────────────┬───────────────────────────────────────────────┘
                                │ Uses
                                │
┌───────────────────────────────▼───────────────────────────────────────────────┐
│                            DOMAIN LAYER (Business Logic)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌──────────────────────────────────────────────────────────────┐           │
│  │                         Use Cases                             │           │
│  ├──────────────────────────────────────────────────────────────┤           │
│  │                                                               │           │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐│           │
│  │  │  GetOrders     │  │GetOrderById    │  │ CreateOrder    ││           │
│  │  │                │  │                │  │                ││           │
│  │  │ - Filter by    │  │ - Fetch single │  │ - Validate qty ││           │
│  │  │   customerId   │  │ - Return order │  │ - Validate amt ││           │
│  │  │ - Filter by    │  │   or NotFound  │  │ - Create order ││           │
│  │  │   status       │  │                │  │                ││           │
│  │  └────────────────┘  └────────────────┘  └────────────────┘│           │
│  │                                                               │           │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐│           │
│  │  │ConfirmOrder    │  │ CancelOrder    │  │UpdateOrderStatus││           │
│  │  │                │  │                │  │                ││           │
│  │  │ - Validate qty │  │ - Validate     │  │ - Validate     ││           │
│  │  │ - Update status│  │   reason       │  │   status value ││           │
│  │  │ - Set timestamp│  │ - Set status   │  │ - Update status││           │
│  │  └────────────────┘  └────────────────┘  └────────────────┘│           │
│  │                                                               │           │
│  └────────────────────────────┬──────────────────────────────────           │
│                                │ Calls                                       │
│                     ┌──────────▼─────────┐                                  │
│                     │ OrderRepository    │                                  │
│                     │   (Interface)      │                                  │
│                     │                    │                                  │
│                     │  Abstract methods: │                                  │
│                     │  - getOrders()     │                                  │
│                     │  - getOrderById()  │                                  │
│                     │  - createOrder()   │                                  │
│                     │  - confirmOrder()  │                                  │
│                     │  - cancelOrder()   │                                  │
│                     │  - updateStatus()  │                                  │
│                     │                    │                                  │
│                     │  Returns:          │                                  │
│                     │  Either<Failure,T> │                                  │
│                     └────────────────────┘                                  │
│                                                                               │
│                     ┌────────────────────┐                                  │
│                     │   Order Entity     │                                  │
│                     │                    │                                  │
│                     │  Properties:       │                                  │
│                     │  - id, orderNumber │                                  │
│                     │  - customerId      │                                  │
│                     │  - status, dates   │                                  │
│                     │  - quantities      │                                  │
│                     │                    │                                  │
│                     │  Methods:          │                                  │
│                     │  - isPending()     │                                  │
│                     │  - canBeCancelled()│                                  │
│                     │  - isFullyConfirmed│                                  │
│                     └────────────────────┘                                  │
│                                                                               │
└───────────────────────────────┬───────────────────────────────────────────────┘
                                │ Implements
                                │
┌───────────────────────────────▼───────────────────────────────────────────────┐
│                          DATA LAYER (Infrastructure)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│                     ┌────────────────────┐                                  │
│                     │OrderRepositoryImpl │                                  │
│                     │                    │                                  │
│                     │  Implements:       │                                  │
│                     │  OrderRepository   │                                  │
│                     │                    │                                  │
│                     │  - Calls DataSource│                                  │
│                     │  - Converts Models │                                  │
│                     │  - Handles Errors  │                                  │
│                     │  - Returns Either  │                                  │
│                     └──────────┬─────────┘                                  │
│                                │ Uses                                        │
│                     ┌──────────▼─────────┐                                  │
│                     │ OrderRemoteDataSource                                 │
│                     │                    │                                  │
│                     │  Interface:        │                                  │
│                     │  - All CRUD methods│                                  │
│                     │                    │                                  │
│                     │  Implementation:   │                                  │
│                     │  - Supabase client │                                  │
│                     │  - SQL queries     │                                  │
│                     │  - Exception throw │                                  │
│                     └──────────┬─────────┘                                  │
│                                │ Returns                                     │
│                     ┌──────────▼─────────┐                                  │
│                     │   OrderModel       │                                  │
│                     │                    │                                  │
│                     │  Extends: Order    │                                  │
│                     │                    │                                  │
│                     │  Methods:          │                                  │
│                     │  - fromJson()      │                                  │
│                     │  - toJson()        │                                  │
│                     │  - toDomain()      │                                  │
│                     │  - fromDomain()    │                                  │
│                     └────────────────────┘                                  │
│                                                                               │
└───────────────────────────────┬───────────────────────────────────────────────┘
                                │ Connects to
                                │
┌───────────────────────────────▼───────────────────────────────────────────────┐
│                          EXTERNAL SERVICES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│                     ┌────────────────────┐                                  │
│                     │  Supabase Database │                                  │
│                     │                    │                                  │
│                     │  Tables:           │                                  │
│                     │  - orders          │                                  │
│                     │  - order_details   │                                  │
│                     │  - profiles        │                                  │
│                     │  - products        │                                  │
│                     │                    │                                  │
│                     │  Features:         │                                  │
│                     │  - PostgreSQL      │                                  │
│                     │  - Real-time       │                                  │
│                     │  - Row Level Sec.  │                                  │
│                     └────────────────────┘                                  │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEPENDENCY INJECTION (Riverpod)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  supabaseClientProvider                                                      │
│           │                                                                   │
│           ▼                                                                   │
│  orderRemoteDataSourceProvider                                               │
│           │                                                                   │
│           ▼                                                                   │
│  orderRepositoryProvider                                                     │
│           │                                                                   │
│           ├──────────────┬──────────────┬──────────────┬─────────────┐      │
│           ▼              ▼              ▼              ▼             ▼      │
│  getOrdersUseCase  getOrderById  createOrder   confirmOrder  cancelOrder    │
│                                                                  │            │
│                                                                  ▼            │
│                                                         updateOrderStatus    │
│           │              │              │              │             │      │
│           └──────────────┴──────────────┴──────────────┴─────────────┘      │
│                                    │                                         │
│                                    ▼                                         │
│                           orderNotifierProvider                              │
│                                    │                                         │
│                                    ▼                                         │
│                              UI Widgets                                      │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                            ERROR FLOW                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Data Source Exception → Repository Failure → Use Case Either → UI Display  │
│                                                                               │
│  ServerException     → ServerFailure     → Left(failure)  → Show error      │
│  NotFoundException  → NotFoundFailure   → Left(failure)  → Show not found   │
│  Generic Exception  → ServerFailure     → Left(failure)  → Show error      │
│                                                                               │
│  Success Path:                                                               │
│  Model              → Entity            → Right(entity)  → Update UI        │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW EXAMPLE: Create Order                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  1. User Input (CreateOrderPage)                                            │
│     ↓                                                                        │
│  2. Validate Form                                                            │
│     ↓                                                                        │
│  3. Create Order Entity                                                      │
│     ↓                                                                        │
│  4. Call orderNotifier.createOrder(order)                                   │
│     ↓                                                                        │
│  5. Notifier calls CreateOrder use case                                     │
│     ↓                                                                        │
│  6. Use case validates (quantity > 0, amount > 0)                           │
│     ↓                                                                        │
│  7. Use case calls repository.createOrder(order)                            │
│     ↓                                                                        │
│  8. Repository converts to OrderModel                                       │
│     ↓                                                                        │
│  9. Repository calls dataSource.createOrder(model)                          │
│     ↓                                                                        │
│  10. DataSource calls Supabase insert                                       │
│     ↓                                                                        │
│  11. Supabase returns created order JSON                                    │
│     ↓                                                                        │
│  12. DataSource converts to OrderModel                                      │
│     ↓                                                                        │
│  13. Repository converts to Order entity                                    │
│     ↓                                                                        │
│  14. Repository returns Right(order)                                        │
│     ↓                                                                        │
│  15. Use case returns Right(order)                                          │
│     ↓                                                                        │
│  16. Notifier updates state with new order                                  │
│     ↓                                                                        │
│  17. UI rebuilds with updated order list                                    │
│     ↓                                                                        │
│  18. Show success message to user                                           │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```
