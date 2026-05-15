import java.sql.*;

public class TableInspector {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/gymora";
        String user = "postgres";
        String password = "123";

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet rs = meta.getColumns(null, null, "memberships", null);
            System.out.println("Columns in memberships table:");
            while (rs.next()) {
                System.out.println(rs.getString("COLUMN_NAME") + " (" + rs.getString("TYPE_NAME") + ") - isNullable: " + rs.getString("IS_NULLABLE"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
