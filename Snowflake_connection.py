import snowflake.connector

# Tus credenciales de Snowflake
user = "Rob1937"
password = "7BSr2xjmt8Ua8Ae"
account = "TC00186"

try:
    # Establecer la conexión
    conn = snowflake.connector.connect(
        user=user,
        password=password,
        account=account
    )

    # Crear un cursor
    cur = conn.cursor()

    # Ejecutar una consulta de prueba
    cur.execute("SELECT current_version()")

    # Obtener el resultado
    one_row = cur.fetchone()
    print("Conexión exitosa. Versión de Snowflake:", one_row[0])

except Exception as e:
    print(f"Error al conectar a Snowflake: {e}")

finally:
    # Cerrar el cursor y la conexión
    if 'cur' in locals() and cur:
        cur.close()
    if 'conn' in locals() and conn:
        conn.close()
