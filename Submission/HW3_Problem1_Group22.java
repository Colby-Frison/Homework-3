import java.sql.Connection;
import java.sql.Statement;
import java.util.Scanner;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.sql.CallableStatement;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

/*
 * CS 4513 - Homework 3, Problem 1
 * Java program using JDBC to manage a Pilot database with menu-driven interface
 * 
 * This program connects to Azure SQL Database and provides operations to:
 * 1. Insert a pilot with hours based on average flight time
 * 2. Insert a pilot with hours based on passenger tier
 * 3. Display all pilots
 * 4. Exit the program
 * 
 * @author [Your Name/Group Number]
 */
public class HW3_Problem1_Group22 {
    
    /* ==================== DATABASE CREDENTIALS ====================
    *  We used github to share the file across team members so we made a .env for credentials 
    *  instead of hardcoding, if you just want to test without .env credentials can be entered below 
    */
    final static String HOSTNAME = "<your4x4>-sql-server.database.windows.net";
    final static String DBNAME = "cs-dsa-4513-sql-db";
    final static String USERNAME = "<your4x4>";
    final static String PASSWORD = "<your_password>";
    
    // Database connection string for Azure SQL
    final static String URL;
    
    // Load credentials from .env if hardcoded values are still placeholders
    static {
        String hostname = HOSTNAME;
        String dbname = DBNAME;
        String username = USERNAME;
        String password = PASSWORD;
        
        // If any hardcoded credential is still a placeholder, try loading from .env
        if (hostname.contains("<your4x4>") || username.contains("<your4x4>") || password.contains("<your_password>")) {
            try {
                Properties props = new Properties();
                FileInputStream fis = new FileInputStream(".env");
                java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(fis));
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.isEmpty() || line.startsWith("#")) continue;
                    int equalIndex = line.indexOf('=');
                    if (equalIndex > 0) {
                        String key = line.substring(0, equalIndex).trim();
                        String value = line.substring(equalIndex + 1).trim();
                        if (value.startsWith("\"") && value.endsWith("\"")) {
                            value = value.substring(1, value.length() - 1);
                        } else if (value.startsWith("'") && value.endsWith("'")) {
                            value = value.substring(1, value.length() - 1);
                        }
                        props.setProperty(key, value);
                    }
                }
                reader.close();
                fis.close();
                
                hostname = props.getProperty("DB_HOSTNAME", hostname);
                dbname = props.getProperty("DB_NAME", dbname);
                username = props.getProperty("DB_USERNAME", username);
                password = props.getProperty("DB_PASSWORD", password);
            } catch (IOException e) {
                // .env file doesn't exist, will use hardcoded values
            }
        }
        
        URL = String.format(
            "jdbc:sqlserver://%s:1433;database=%s;user=%s;password=%s;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;",
            hostname, dbname, username, password
        );
    }
    
    // ==================== STORED PROCEDURE CALLS ====================
    // Stored procedure call to insert pilot based on average flight time
    final static String SP_INSERT_PILOT_AVG_FLIGHT = "{CALL InsertPilotAvgFlightTime(?, ?)}";
    
    // Stored procedure call to insert pilot based on passenger tier
    final static String SP_INSERT_PILOT_BY_TIER = "{CALL InsertPilotByPassengerTier(?, ?, ?)}";
    
    // Query to display all pilots sorted by pIid
    final static String QUERY_DISPLAY_ALL_PILOTS = "SELECT pIid, pIname, hours FROM Pilot ORDER BY pIid;";
    
    // ==================== USER MENU PROMPT ====================
    final static String MENU_PROMPT = 
        "\n========================================\n" +
        "     PILOT MANAGEMENT SYSTEM\n" +
        "========================================\n" +
        "Please select one of the options below:\n" +
        "1) Insert Pilot (Hours Based on Average Flight Time)\n" +
        "2) Insert Pilot (Hours Based on Passenger Tier)\n" +
        "3) Display All Pilots\n" +
        "4) Quit\n" +
        "========================================\n" +
        "Enter your choice: ";
    
    /**
     * Main method - Entry point of the program
     * Implements menu-driven interface for pilot management operations
     */
    public static void main(String[] args) {
        System.out.println("\n===========================================");
        System.out.println("   Welcome to Pilot Management System!");
        System.out.println("   CS 4513 - Homework 3, Problem 1");
        System.out.println("===========================================\n");
        
        // Scanner to collect user input
        final Scanner sc = new Scanner(System.in);
        String option = "";
        
        // Main program loop - continues until user selects option 4 (Quit)
        while (!option.equals("4")) {
            System.out.print(MENU_PROMPT);
            option = sc.next();
            sc.nextLine(); // Consume the newline character
            
            try {
                switch (option) {
                    case "1":
                        // Option 1: Insert pilot with hours based on average flight time
                        insertPilotAvgFlightTime(sc);
                        break;
                        
                    case "2":
                        // Option 2: Insert pilot with hours based on passenger tier
                        insertPilotByTier(sc);
                        break;
                        
                    case "3":
                        // Option 3: Display all pilots
                        displayAllPilots();
                        break;
                        
                    case "4":
                        // Option 4: Exit the program
                        System.out.println("\n===========================================");
                        System.out.println("   Exiting Pilot Management System.");
                        System.out.println("   Thank you for using our system!");
                        System.out.println("===========================================\n");
                        break;
                        
                    default:
                        // Handle invalid menu option
                        System.out.println("\n[ERROR] Unrecognized option: " + option);
                        System.out.println("Please enter a number between 1 and 4.\n");
                        break;
                }
            } catch (SQLException e) {
                // Handle any SQL errors that occur during operations
                System.err.println("\n[SQL ERROR] An error occurred:");
                System.err.println("Error Message: " + e.getMessage());
                System.err.println("SQL State: " + e.getSQLState());
                System.err.println("Error Code: " + e.getErrorCode());
                System.err.println("\nPlease try again or contact system administrator.\n");
            } catch (Exception e) {
                // Handle any other unexpected errors
                System.err.println("\n[SYSTEM ERROR] An unexpected error occurred:");
                System.err.println(e.getMessage());
                System.err.println("\nPlease try again.\n");
            }
        }
        
        // Close the scanner before exiting
        sc.close();
    }
    
    /**
     * Option 1: Insert a new pilot with hours calculated based on average flight time
     * Calls the stored procedure InsertPilotAvgFlightTime
     * 
     * The stored procedure calculates hours as the average flight time of all flights
     * in the Flight table by subtracting dep_time from arrival_time.
     * If no flights exist, hours is set to 0.
     * 
     * @param sc Scanner object for reading user input
     * @throws SQLException if database error occurs
     */
    private static void insertPilotAvgFlightTime(Scanner sc) throws SQLException {
        System.out.println("\n--- Insert Pilot (Average Flight Time) ---");
        
        // Collect pilot ID from user
        System.out.print("Enter Pilot ID (pIid): ");
        final int pIid = sc.nextInt();
        sc.nextLine(); // Consume newline
        
        // Collect pilot name from user
        System.out.print("Enter Pilot Name (pIname): ");
        final String pIname = sc.nextLine();
        
        System.out.println("\nConnecting to database...");
        
        // Establish database connection and execute stored procedure
        try (final Connection connection = DriverManager.getConnection(URL)) {
            // Prepare the stored procedure call
            try (final CallableStatement statement = connection.prepareCall(SP_INSERT_PILOT_AVG_FLIGHT)) {
                // Set input parameters for the stored procedure
                statement.setInt(1, pIid);
                statement.setString(2, pIname);
                
                System.out.println("Executing stored procedure...");
                
                // Execute the stored procedure
                final int rowsInserted = statement.executeUpdate();
                
                System.out.println("\n[SUCCESS] Pilot inserted successfully!");
                System.out.println("Rows affected: " + rowsInserted);
                System.out.println("Hours calculated based on average flight time of all flights.\n");
            }
        }
    }
    
    /**
     * Option 2: Insert a new pilot with hours calculated based on passenger tier
     * Calls the stored procedure InsertPilotByPassengerTier
     * 
     * The stored procedure calculates hours as the average flight time of all flights
     * piloted by pilots who have at least one passenger of the specified tier.
     * If no such flights exist, hours is set to 0.
     * 
     * @param sc Scanner object for reading user input
     * @throws SQLException if database error occurs
     */
    private static void insertPilotByTier(Scanner sc) throws SQLException {
        System.out.println("\n--- Insert Pilot (By Passenger Tier) ---");
        
        // Collect pilot ID from user
        System.out.print("Enter Pilot ID (pIid): ");
        final int pIid = sc.nextInt();
        sc.nextLine(); // Consume newline
        
        // Collect pilot name from user
        System.out.print("Enter Pilot Name (pIname): ");
        final String pIname = sc.nextLine();
        
        // Collect passenger tier from user
        System.out.print("Enter Passenger Tier (e.g., Gold, Silver, Bronze): ");
        final String tier = sc.nextLine();
        
        System.out.println("\nConnecting to database...");
        
        // Establish database connection and execute stored procedure
        try (final Connection connection = DriverManager.getConnection(URL)) {
            // Prepare the stored procedure call
            try (final CallableStatement statement = connection.prepareCall(SP_INSERT_PILOT_BY_TIER)) {
                // Set input parameters for the stored procedure
                statement.setInt(1, pIid);
                statement.setString(2, pIname);
                statement.setString(3, tier);
                
                System.out.println("Executing stored procedure...");
                
                // Execute the stored procedure
                final int rowsInserted = statement.executeUpdate();
                
                System.out.println("\n[SUCCESS] Pilot inserted successfully!");
                System.out.println("Rows affected: " + rowsInserted);
                System.out.println("Hours calculated based on flights with " + tier + " tier passengers.\n");
            }
        }
    }
    
    /**
     * Option 3: Display all pilots in the Pilot table
     * Shows pIid, pIname, and hours for all pilots, sorted by pIid
     * 
     * @throws SQLException if database error occurs
     */
    private static void displayAllPilots() throws SQLException {
        System.out.println("\nConnecting to database...");
        
        // Establish database connection and execute query
        try (final Connection connection = DriverManager.getConnection(URL)) {
            System.out.println("Retrieving pilot records...\n");
            
            // Create statement and execute query
            try (final Statement statement = connection.createStatement();
                 final ResultSet resultSet = statement.executeQuery(QUERY_DISPLAY_ALL_PILOTS)) {
                
                // Display table header
                System.out.println("=================================================================");
                System.out.println("                    ALL PILOTS IN DATABASE");
                System.out.println("=================================================================");
                System.out.println(String.format("%-10s | %-30s | %-10s", 
                    "Pilot ID", "Pilot Name", "Hours"));
                System.out.println("-----------------------------------------------------------------");
                
                // Track if any records were found
                boolean hasRecords = false;
                
                // Iterate through result set and display each pilot record
                while (resultSet.next()) {
                    hasRecords = true;
                    final int pIid = resultSet.getInt("pIid");
                    final String pIname = resultSet.getString("pIname");
                    final double hours = resultSet.getDouble("hours");
                    
                    // Format and print each pilot's information
                    System.out.println(String.format("%-10d | %-30s | %-10.2f", 
                        pIid, pIname, hours));
                }
                
                System.out.println("=================================================================");
                
                // Notify user if no records were found
                if (!hasRecords) {
                    System.out.println("No pilot records found in the database.");
                } else {
                    System.out.println("End of pilot records.\n");
                }
            }
        }
    }
}

