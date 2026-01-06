-- Add new columns for enhanced features
alter table public.rides add column if not exists pickup_address text;
alter table public.rides add column if not exists destination_address text;
alter table public.rides add column if not exists driver_lat double precision;
alter table public.rides add column if not exists driver_lng double precision;
alter table public.rides add column if not exists fare double precision;
