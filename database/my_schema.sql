-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.deliveries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shipment_id uuid,
  driver_id uuid,
  status character varying DEFAULT 'pending'::character varying,
  pickup_photo text,
  delivery_photo text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT deliveries_pkey PRIMARY KEY (id),
  CONSTRAINT deliveries_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id),
  CONSTRAINT deliveries_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.driver_locations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL,
  latitude numeric NOT NULL,
  longitude numeric NOT NULL,
  timestamp timestamp with time zone DEFAULT now(),
  shipment_id uuid,
  accuracy numeric,
  speed numeric,
  heading numeric,
  CONSTRAINT driver_locations_pkey PRIMARY KEY (id),
  CONSTRAINT driver_locations_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id),
  CONSTRAINT driver_locations_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.driver_performance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  driver_id uuid,
  month_year character varying NOT NULL,
  total_deliveries integer DEFAULT 0,
  average_rating numeric DEFAULT 0.00,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT driver_performance_pkey PRIMARY KEY (id),
  CONSTRAINT driver_performance_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title character varying NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  category text DEFAULT 'system'::text,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.order_details (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  product_id uuid NOT NULL,
  requested_quantity numeric NOT NULL,
  confirmed_quantity numeric DEFAULT 0,
  unit_price numeric NOT NULL,
  subtotal numeric NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_details_pkey PRIMARY KEY (id),
  CONSTRAINT order_details_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_details_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_number character varying NOT NULL UNIQUE,
  customer_id uuid NOT NULL,
  order_date timestamp with time zone DEFAULT now(),
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'confirmed'::character varying, 'shipped'::character varying, 'completed'::character varying, 'cancelled'::character varying]::text[])),
  total_quantity numeric NOT NULL,
  confirmed_quantity numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  admin_notes text,
  customer_notes text,
  pickup_address text,
  delivery_address text,
  pickup_date timestamp with time zone,
  delivery_date timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  confirmed_at timestamp with time zone,
  notes text,
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  description text,
  price_per_ton numeric NOT NULL,
  stock_available numeric DEFAULT 0,
  min_order_quantity integer DEFAULT 1,
  category character varying NOT NULL DEFAULT 'Palm Shell'::character varying,
  product_code character varying UNIQUE,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  unit character varying DEFAULT 'ton'::character varying,
  CONSTRAINT products_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying DEFAULT 'User'::character varying,
  role_id integer,
  phone character varying,
  address text,
  is_active boolean DEFAULT true,
  avatar_url text,
  city character varying,
  province character varying,
  postal_code character varying,
  driver_license character varying,
  vehicle_type character varying,
  vehicle_plate character varying,
  company_name character varying,
  job_title character varying,
  latitude double precision CHECK (latitude >= '-90'::integer::double precision AND latitude <= 90::double precision),
  longitude double precision CHECK (longitude >= '-180'::integer::double precision AND longitude <= 180::double precision),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT profiles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id)
);
CREATE TABLE public.roles (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  name character varying NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.shipment_timeline (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shipment_id uuid NOT NULL,
  status character varying NOT NULL,
  message text NOT NULL,
  location_lat numeric,
  location_lng numeric,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipment_timeline_pkey PRIMARY KEY (id),
  CONSTRAINT shipment_timeline_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id)
);
CREATE TABLE public.shipments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  driver_id uuid NOT NULL,
  delivery_note_number character varying NOT NULL UNIQUE,
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'in_transit'::character varying, 'arrived'::character varying, 'completed'::character varying]::text[])),
  destination_lat double precision,
  destination_lng double precision,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  destination_address text,
  delivery_note_url text,
  notes text,
  pickup_date timestamp with time zone,
  assigned_at timestamp with time zone,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  estimated_arrival timestamp with time zone,
  actual_delivery timestamp with time zone,
  tracking_number character varying,
  CONSTRAINT shipments_pkey PRIMARY KEY (id),
  CONSTRAINT shipments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT shipments_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.tasks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  driver_id uuid,
  title character varying NOT NULL,
  description text,
  status USER-DEFINED DEFAULT 'Scheduled'::task_status,
  priority integer DEFAULT 1,
  scheduled_date timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tasks_pkey PRIMARY KEY (id),
  CONSTRAINT tasks_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT tasks_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id)
);