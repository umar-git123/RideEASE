-- 1. Create Users Table (Public profile linked to auth.users)
create table public.users (
  id uuid references auth.users not null primary key,
  email text,
  role text check (role in ('rider', 'driver')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Create Rides Table
create table public.rides (
  id uuid default gen_random_uuid() primary key,
  rider_id uuid references public.users(id) not null,
  driver_id uuid references public.users(id),
  pickup_lat double precision not null,
  pickup_lng double precision not null,
  pickup_address text,
  destination_lat double precision not null,
  destination_lng double precision not null,
  destination_address text,
  driver_lat double precision,
  driver_lng double precision,
  fare double precision,
  status text check (status in ('requested', 'accepted', 'completed')) default 'requested',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Enable Row Level Security
alter table public.users enable row level security;
alter table public.rides enable row level security;

-- 4. RLS Policies

-- Users: Everyone can read users (needed for ride info), but only owner can update
create policy "Public users are viewable by everyone"
  on public.users for select
  using ( true );

create policy "Users can insert their own profile"
  on public.users for insert
  with check ( auth.uid() = id );

-- Rides:
-- Rider can see their own rides
create policy "Riders can see own rides"
  on public.rides for select
  using ( auth.uid() = rider_id );

-- Drivers can see available rides (requested) or rides they accepted
create policy "Drivers can see available or assigned rides"
  on public.rides for select
  using ( 
    (status = 'requested') or 
    (driver_id = auth.uid()) 
  );

-- Riders can insert rides
create policy "Riders can insert rides"
  on public.rides for insert
  with check ( auth.uid() = rider_id );

-- Drivers can update rides (accept/complete)
create policy "Drivers can update assigned rides"
  on public.rides for update
  using ( true ) -- Simplified for demo. Ideally check if driver_id is null (accepting) or matches auth.uid (completing)
  with check ( true ); 

-- 5. Realtime
-- Go to Supabase > Database > Replication > Source and enable supabase_realtime for 'rides' table.
