# API Documentation - Cangkang Sawit App

## Overview

Aplikasi ini menggunakan Supabase sebagai Backend-as-a-Service (BaaS) dengan PostgreSQL database, Authentication, Storage, dan Real-time capabilities.

## Base URL

```
https://your-project-id.supabase.co
```

## Authentication

### Headers

Semua request yang memerlukan autentikasi harus menyertakan header:

```
Authorization: Bearer <jwt_token>
apikey: <supabase_anon_key>
```

### Login

```http
POST /auth/v1/token?grant_type=password
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "access_token": "jwt_token_here",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "refresh_token_here",
  "user": {
    "id": "uuid",
    "email": "user@example.com"
    // ... user data
  }
}
```

### Register

```http
POST /auth/v1/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "data": {
    "full_name": "John Doe",
    "role_id": 2
  }
}
```

### Logout

```http
POST /auth/v1/logout
Authorization: Bearer <jwt_token>
```

## Database API Endpoints

### Base URL untuk REST API

```
https://your-project-id.supabase.co/rest/v1/
```

### 1. Roles

#### Get All Roles

```http
GET /rest/v1/roles?select=*
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "Admin",
    "description": "Administrator sistem",
    "created_at": "2025-01-01T00:00:00Z"
  },
  {
    "id": 2,
    "name": "Mitra Bisnis",
    "description": "Partner bisnis yang dapat membuat pesanan",
    "created_at": "2025-01-01T00:00:00Z"
  }
]
```

### 2. User Profiles

#### Get User Profile

```http
GET /rest/v1/profiles?select=*,roles(*)&user_id=eq.<user_id>
```

#### Update User Profile

```http
PATCH /rest/v1/profiles?user_id=eq.<user_id>
Content-Type: application/json

{
  "full_name": "Updated Name",
  "phone": "+62812345678",
  "address": "New Address"
}
```

### 3. Products

#### Get All Products

```http
GET /rest/v1/products?select=*&is_active=eq.true
```

#### Create Product (Admin only)

```http
POST /rest/v1/products
Content-Type: application/json

{
  "name": "Cangkang Kelapa Sawit Premium",
  "description": "Kualitas terbaik",
  "price_per_kg": 1500.00,
  "unit": "kg",
  "is_active": true
}
```

#### Update Product (Admin only)

```http
PATCH /rest/v1/products?id=eq.<product_id>
Content-Type: application/json

{
  "price_per_kg": 1600.00,
  "is_active": false
}
```

### 4. Orders

#### Get Orders (with filters)

```http
# Admin: Get all orders
GET /rest/v1/orders?select=*,profiles(full_name),order_details(*)

# Mitra Bisnis: Get own orders only (handled by RLS)
GET /rest/v1/orders?select=*,order_details(*,products(*))&user_id=eq.<user_id>
```

#### Create Order

```http
POST /rest/v1/orders
Content-Type: application/json

{
  "order_number": "FBE20250101001",
  "delivery_address": "Jl. Industri No. 123",
  "delivery_date": "2025-01-15",
  "notes": "Harap kirim pagi hari"
}
```

#### Update Order Status (Admin only)

```http
PATCH /rest/v1/orders?id=eq.<order_id>
Content-Type: application/json

{
  "status": "Dikonfirmasi",
  "confirmed_at": "2025-01-01T10:00:00Z",
  "confirmed_by": "<admin_user_id>"
}
```

### 5. Order Details

#### Add Order Items

```http
POST /rest/v1/order_details
Content-Type: application/json

{
  "order_id": "<order_uuid>",
  "product_id": "<product_uuid>",
  "quantity": 1000,
  "price_per_kg": 1500.00
}
```

#### Update Partial Acceptance

```http
PATCH /rest/v1/order_details?id=eq.<detail_id>
Content-Type: application/json

{
  "accepted_quantity": 800,
  "notes": "Stok terbatas, hanya tersedia 800kg"
}
```

### 6. Shipments

#### Get Shipments

```http
# Admin: All shipments
GET /rest/v1/shipments?select=*,orders(*),profiles(full_name)

# Driver: Own shipments only
GET /rest/v1/shipments?select=*,orders(*)&driver_id=eq.<driver_id>
```

#### Create Shipment (Admin only)

```http
POST /rest/v1/shipments
Content-Type: application/json

{
  "order_id": "<order_uuid>",
  "driver_id": "<driver_user_id>",
  "vehicle_number": "B 1234 XYZ",
  "surat_jalan_url": "https://supabase.co/storage/v1/object/public/surat-jalan/file.pdf"
}
```

#### Update Shipment Status

```http
PATCH /rest/v1/shipments?id=eq.<shipment_id>
Content-Type: application/json

{
  "status": "Dalam Perjalanan",
  "departure_time": "2025-01-01T08:00:00Z"
}
```

### 7. Driver Locations (GPS Tracking)

#### Insert Location Update

```http
POST /rest/v1/driver_locations
Content-Type: application/json

{
  "user_id": "<driver_user_id>",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "accuracy": 5.0,
  "speed": 60.5,
  "heading": 180.0
}
```

#### Get Latest Driver Location

```http
GET /rest/v1/driver_locations?select=*&user_id=eq.<driver_id>&order=created_at.desc&limit=1
```

#### Get Location History

```http
GET /rest/v1/driver_locations?select=*&user_id=eq.<driver_id>&created_at=gte.2025-01-01T00:00:00Z&order=created_at.desc
```

## Storage API

### Base URL untuk Storage

```
https://your-project-id.supabase.co/storage/v1/
```

### Upload Surat Jalan (PDF)

```http
POST /storage/v1/object/surat-jalan/<filename>.pdf
Authorization: Bearer <jwt_token>
Content-Type: application/pdf

<pdf_file_data>
```

### Upload Bukti Kirim (Image)

```http
POST /storage/v1/object/bukti-kirim/<filename>.jpg
Authorization: Bearer <jwt_token>
Content-Type: image/jpeg

<image_file_data>
```

### Get File URL

```http
GET /storage/v1/object/public/surat-jalan/<filename>.pdf
```

### Delete File

```http
DELETE /storage/v1/object/surat-jalan/<filename>.pdf
Authorization: Bearer <jwt_token>
```

## Real-time Subscriptions

### Listen to Driver Location Updates

```javascript
const subscription = supabase
  .channel("driver_tracking")
  .on(
    "postgres_changes",
    {
      event: "INSERT",
      schema: "public",
      table: "driver_locations",
      filter: "user_id=eq.<driver_id>",
    },
    (payload) => {
      console.log("Location update:", payload.new);
    }
  )
  .subscribe();
```

### Listen to Order Status Changes

```javascript
const subscription = supabase
  .channel("order_updates")
  .on(
    "postgres_changes",
    {
      event: "UPDATE",
      schema: "public",
      table: "orders",
      filter: "user_id=eq.<user_id>",
    },
    (payload) => {
      console.log("Order updated:", payload.new);
    }
  )
  .subscribe();
```

### Listen to Shipment Updates

```javascript
const subscription = supabase
  .channel("shipment_updates")
  .on(
    "postgres_changes",
    {
      event: "*",
      schema: "public",
      table: "shipments",
    },
    (payload) => {
      console.log("Shipment updated:", payload);
    }
  )
  .subscribe();
```

## Error Responses

### Standard Error Format

```json
{
  "error": {
    "message": "Error description",
    "details": "Detailed error information",
    "hint": "Suggestion to fix the error",
    "code": "ERROR_CODE"
  }
}
```

### Common Error Codes

- `PGRST301`: Row Level Security violation
- `PGRST116`: JSON object requested, but multiple (or no) rows returned
- `23505`: Unique constraint violation
- `23503`: Foreign key constraint violation
- `42501`: Insufficient privilege

## Rate Limits

- **API Requests**: 100 requests per minute per IP
- **Storage Uploads**: 10 MB per file, 100 MB per hour
- **Real-time Connections**: 200 concurrent connections

## Data Types & Formats

### Timestamps

All timestamps are in ISO 8601 format with timezone:

```
2025-01-01T10:30:00+00:00
```

### Currency

Currency values are stored as `DECIMAL(10,2)`:

```json
{
  "price_per_kg": 1500.0
}
```

### GPS Coordinates

```json
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "accuracy": 5.0
}
```

### File URLs

```
https://your-project-id.supabase.co/storage/v1/object/public/bucket-name/file-name.ext
```

## Security Notes

1. **Row Level Security (RLS)** is enabled on all tables
2. Users can only access data based on their role and ownership
3. File uploads require authentication
4. API keys should never be exposed in client-side code
5. Use JWT tokens for authenticated requests
6. Implement proper input validation on client-side

## Testing

### Test Endpoints with curl

```bash
# Get all products
curl -X GET 'https://your-project-id.supabase.co/rest/v1/products?select=*' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Create order
curl -X POST 'https://your-project-id.supabase.co/rest/v1/orders' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "order_number": "FBE20250101001",
    "delivery_address": "Test Address"
  }'
```

---

📚 **Additional Resources:**

- [Supabase API Documentation](https://supabase.com/docs/guides/api)
- [PostgREST API Reference](https://postgrest.org/en/stable/api.html)
