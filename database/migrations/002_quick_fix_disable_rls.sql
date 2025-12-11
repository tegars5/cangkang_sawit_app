-- Quick Fix: Temporarily disable RLS on shipments table
-- Use this ONLY if you want to test quickly without proper policies
-- NOT RECOMMENDED for production!

ALTER TABLE public.shipments DISABLE ROW LEVEL SECURITY;

-- To re-enable later with proper policies, run:
-- ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
-- Then run 002_add_shipments_rls_policies.sql
