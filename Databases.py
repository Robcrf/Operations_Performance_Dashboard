#Import python libraries
import csv
import random
from faker import Faker
from datetime import timedelta

#Initializer Faker

fake = Faker()

# -------------------------------
# INPUTS
# -------------------------------

num_rows = int(input("Enter number of sales rows to generate: "))

ventas_file = "ventas.csv"
produccion_file = "produccion.csv"
inventario_file = "inventario.csv"


# -------------------------------
# MASTER DATA
# -------------------------------
customers = [
    "Cliente Automotriz A",
    "Cliente Construccion B",
    "Cliente Industrial C",
    "Cliente Exportacion D"
]

products = [
    "Vidrio Templado",
    "Vidrio Laminado",
    "Vidrio Flotado"
]

warehouses = [
    "Planta Monterrey",
    "Planta Toluca",
    "Planta Queretaro"
]


# ===============================
# 1️⃣ GENERATE SALES DATA
# ===============================
with open(ventas_file, mode="w", newline="") as file:
    writer = csv.writer(file)

    header = [
        "order_id",
        "customer",
        "product",
        "quantity",
        "unit_price",
        "order_date",
        "delivery_date",
        "total_sales"
    ]

    writer.writerow(header)

    for i in range(1, num_rows + 1):
        quantity = random.randint(50, 500)
        unit_price = round(random.uniform(120, 350), 2)

        order_date = fake.date_between(start_date="-1y", end_date="today")
        delivery_date = order_date + timedelta(days=random.randint(2, 15))

        row = [
            i,
            random.choice(customers),
            random.choice(products),
            quantity,
            unit_price,
            order_date,
            delivery_date,
            round(quantity * unit_price, 2)
        ]

        writer.writerow(row)



# ===============================
# 2️⃣ GENERATE PRODUCTION DATA
# ===============================
with open(produccion_file, mode="w", newline="") as file:
    writer = csv.writer(file)

    header = [
        "production_id",
        "product",
        "production_date",
        "units_produced",
        "scrap_units"
    ]

    writer.writerow(header)

    for i in range(1, 53):  # weekly production
        for product in products:
            units_produced = random.randint(1000, 5000)
            scrap_units = int(units_produced * random.uniform(0.02, 0.08))

            row = [
                f"P{i}",
                product,
                fake.date_between(start_date="-1y", end_date="today"),
                units_produced,
                scrap_units
            ]

            writer.writerow(row)



# ===============================
# 3️⃣ GENERATE INVENTORY DATA
# ===============================
with open(inventario_file, mode="w", newline="") as file:
    writer = csv.writer(file)

    header = [
        "product",
        "warehouse",
        "stock_units",
        "last_update"
    ]

    writer.writerow(header)

    for product in products:
        for warehouse in warehouses:
            row = [
                product,
                warehouse,
                random.randint(800, 5000),
                fake.date_between(start_date="-30d", end_date="today")
            ]

            writer.writerow(row)


# -------------------------------
# SUCCESS MESSAGE
# -------------------------------
print("CSV files generated successfully:")
print("- ventas.csv")
print("- produccion.csv")
print("- inventario.csv")