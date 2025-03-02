const Database = require('better-sqlite3');
const bcrypt = require('bcrypt');

const better_sqlite_client = new Database('cspanel.db');

better_sqlite_client.exec(`
  CREATE TABLE IF NOT EXISTS servers (
    id INTEGER PRIMARY KEY,
    serverIP TEXT NOT NULL,
    serverPort INTEGER NOT NULL,
    rconPassword TEXT NOT NULL
  )
`);

better_sqlite_client.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
  )
`);

const username = process.env.PANEL_USERNAME;
const password = process.env.PANEL_PASSWORD;
// Hash the default password
const hashed_password = bcrypt.hashSync(password, 10);

// Check if the default user already exists
const existing_user = better_sqlite_client.prepare(`
  SELECT * FROM users WHERE username = ?
`).get(username);

if (existing_user) {
    console.log('Default user already exists');
} else {
    // Insert the default user into the users table
    const insert_query = better_sqlite_client.prepare(`
    INSERT INTO users (username, password)
    VALUES (?, ?)
  `);

    insert_query.run(username, hashed_password);
    console.log('Default user created successfully.');
}
module.exports = {
    better_sqlite_client
};
