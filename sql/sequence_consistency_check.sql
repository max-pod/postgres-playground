-- Step 1: Create the sequence
CREATE SEQUENCE my_sequence START WITH 1;

-- Step 2: Create the table with default 'id'
CREATE TABLE my_table (
    id TEXT PRIMARY KEY DEFAULT md5(nextval('my_sequence')::text),
    data TEXT NOT NULL
);

-- Step 3: Insert data without specifying 'id'
INSERT INTO my_table (data) VALUES ('Sample Data');
INSERT INTO my_table (data) VALUES ('Another Sample');

-- Step 4: Query the table
SELECT id, data FROM my_table;