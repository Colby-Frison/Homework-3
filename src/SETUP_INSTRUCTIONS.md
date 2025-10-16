# Setup Instructions for Problem1.java

## Database Configuration

This program uses a `.env` file to store sensitive database credentials separately from the source code. This is a security best practice that prevents credentials from being accidentally committed to version control.

### Initial Setup

1. **Create a `.env` file in the project root directory**

2. **Add your Azure SQL credentials in the following format:**
   ```env
   DB_HOSTNAME=your4x4-sql-server.database.windows.net
   DB_NAME=cs-dsa-4513-sql-db
   DB_USERNAME=your4x4
   DB_PASSWORD=your_actual_password
   ```

3. **Replace the placeholder values:**
   - `your4x4`: Replace with your actual 4x4 ID (e.g., `abc1`)
   - `your_actual_password`: Replace with your Azure SQL password

### File Structure

```
Homework 3/
├── .env                             # Your credentials (DO NOT commit)
├── .gitignore                       # Configured to exclude .env
└── src/
    ├── Problem1.java                # Main Java program
    └── SETUP_INSTRUCTIONS.md        # This file
```

### Security Notes

- ❌ **DO NOT commit:** `.env` (contains real credentials)
- ✅ The `.gitignore` file is configured to exclude `.env`
- ✅ Share the setup instructions, not your credentials

### Compilation and Execution

**Compile:**
```bash
javac Problem1.java
```

**Run:**
```bash
java Problem1
```

**Run with JDBC driver:**
```bash
java -cp ".;mssql-jdbc-12.4.0.jre11.jar" Problem1
```

### Troubleshooting

**Error: "Unable to load .env file"**
- Make sure `.env` exists in the project root directory (same level as `src/`)
- Create a new `.env` file with the required format if needed

**Error: "Missing required database credentials"**
- Check that all four variables are set in `.env`
- Variable names are case-sensitive: `DB_HOSTNAME`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`
- Make sure there are no spaces around the `=` sign

**Error: "Login failed for user"**
- Verify your credentials are correct
- Check Azure SQL firewall settings
- Ensure your IP address is whitelisted

### Benefits of This Approach

1. **Security**: Credentials are not in source code
2. **Flexibility**: Easy to change credentials without modifying code
3. **Team-friendly**: Each team member can have their own `.env` file
4. **Version control safe**: `.env` is excluded from git
5. **Industry standard**: `.env` files are widely used in modern development

### .env File Format

The `.env` file uses a simple `KEY=VALUE` format:
- One variable per line
- Comments start with `#`
- Quotes around values are optional
- No spaces around the `=` sign

Example:
```env
# Azure SQL Database Configuration
DB_HOSTNAME=abc1-sql-server.database.windows.net
DB_NAME=cs-dsa-4513-sql-db
DB_USERNAME=abc1
DB_PASSWORD=MySecurePassword123!
```

