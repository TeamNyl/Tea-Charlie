-- Multiplayer room/session/world instance
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- One player can be in multiple rooms (e.g., minigames, overworld), and track coords there
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,

    map_x FLOAT NOT NULL DEFAULT 0,
    map_y FLOAT NOT NULL DEFAULT 0,

    state JSONB DEFAULT '{}' -- Optional: carry state like `emote`, `tea_in_hand`, etc.
);

-- You can keep this for persistent data
CREATE TABLE user_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    coins INT NOT NULL DEFAULT 400,

    created_teas JSONB[] NOT NULL DEFAULT '{}',
    achievements JSONB[] NOT NULL DEFAULT '{}',
    inventory JSONB[] NOT NULL DEFAULT '{}'
);
