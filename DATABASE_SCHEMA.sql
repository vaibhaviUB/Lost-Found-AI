-- Supabase SQL Schema for Lost&Found Messaging System
-- Run these commands in your Supabase SQL Editor

-- 1. Profiles Table (if not exists)
create table if not exists profiles (
  id uuid primary key references auth.users(id),
  full_name text,
  avatar_url text,
  phone text,
  location text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 2. Lost Items Table
create table if not exists lost_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  category text not null,
  description text,
  location text,
  specific_location text,
  color text,
  brand text,
  identifying_features text,
  reward_offered numeric,
  lost_date timestamp with time zone,
  images text[] default '{}',
  latitude numeric,
  longitude numeric,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 3. Found Items Table
create table if not exists found_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  category text not null,
  description text,
  location text,
  specific_location text,
  color text,
  brand text,
  identifying_features text,
  found_date timestamp with time zone,
  images text[] default '{}',
  latitude numeric,
  longitude numeric,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 4. Handovers Table (if not exists)
create table if not exists handovers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references profiles(id) on delete cascade,
  finder_id uuid not null references profiles(id) on delete cascade,
  lost_item_id uuid references lost_items(id) on delete set null,
  found_item_id uuid references found_items(id) on delete set null,
  status text default 'pending_verification',
  match_score integer,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 5. Handover Messages Table (NEW)
create table if not exists handover_messages (
  id uuid primary key default gen_random_uuid(),
  handover_id uuid not null references handovers(id) on delete cascade,
  sender_id uuid not null references profiles(id) on delete cascade,
  content text not null,
  read boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 6. Create indexes for better performance
create index if not exists idx_lost_items_user_id 
  on lost_items(user_id);
create index if not exists idx_found_items_user_id 
  on found_items(user_id);
create index if not exists idx_lost_items_created_at 
  on lost_items(created_at);
create index if not exists idx_found_items_created_at 
  on found_items(created_at);
create index if not exists idx_handover_messages_handover_id 
  on handover_messages(handover_id);
create index if not exists idx_handover_messages_sender_id 
  on handover_messages(sender_id);
create index if not exists idx_handover_messages_created_at 
  on handover_messages(created_at);
create index if not exists idx_handovers_owner_id 
  on handovers(owner_id);
create index if not exists idx_handovers_finder_id 
  on handovers(finder_id);

-- 7. Enable Row Level Security (RLS)
alter table lost_items enable row level security;
alter table found_items enable row level security;
alter table handover_messages enable row level security;
alter table handovers enable row level security;

-- 8. RLS Policies for lost_items (users can only see all lost items, but only update/delete their own)
create policy "Anyone can view lost items"
  on lost_items for select
  using (true);

create policy "Users can create lost items"
  on lost_items for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own lost items"
  on lost_items for update
  using (auth.uid() = user_id);

create policy "Users can delete their own lost items"
  on lost_items for delete
  using (auth.uid() = user_id);

-- 9. RLS Policies for found_items (users can only see all found items, but only update/delete their own)
create policy "Anyone can view found items"
  on found_items for select
  using (true);

create policy "Users can create found items"
  on found_items for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own found items"
  on found_items for update
  using (auth.uid() = user_id);

create policy "Users can delete their own found items"
  on found_items for delete
  using (auth.uid() = user_id);
-- 10. RLS Policies for handovers (users can only see their own handovers)
create policy "Users can see their own handovers"
  on handovers for select
  using (auth.uid() = owner_id or auth.uid() = finder_id);

create policy "Users can create handovers"
  on handovers for insert
  with check (auth.uid() = owner_id or auth.uid() = finder_id);

create policy "Users can update their own handovers"
  on handovers for update
  using (auth.uid() = owner_id or auth.uid() = finder_id);

-- 11. RLS Policies for messages (users can only see messages in their handovers)
create policy "Users can see messages in their handovers"
  on handover_messages for select
  using (
    exists (
      select 1 from handovers
      where handovers.id = handover_messages.handover_id
      and (handovers.owner_id = auth.uid() or handovers.finder_id = auth.uid())
    )
  );

create policy "Users can send messages in their handovers"
  on handover_messages for insert
  with check (
    auth.uid() = sender_id and
    exists (
      select 1 from handovers
      where handovers.id = handover_messages.handover_id
      and (handovers.owner_id = auth.uid() or handovers.finder_id = auth.uid())
    )
  );

create policy "Users can mark their own messages as read"
  on handover_messages for update
  using (
    exists (
      select 1 from handovers
      where handovers.id = handover_messages.handover_id
      and (handovers.owner_id = auth.uid() or handovers.finder_id = auth.uid())
    )
  );

-- 12. Create a trigger to update handovers.updated_at when a message is sent
create or replace function update_handover_timestamp()
returns trigger as $$
begin
  update handovers set updated_at = now() where id = new.handover_id;
  return new;
end;
$$ language plpgsql;

create trigger handover_messages_update_timestamp
after insert on handover_messages
for each row
execute function update_handover_timestamp();

-- 13. Create a function to mark messages as read for current user
create or replace function mark_messages_read(handover_id_param uuid)
returns void as $$
begin
  update handover_messages
  set read = true
  where handover_id = handover_id_param
  and sender_id != auth.uid();
end;
$$ language plpgsql;
