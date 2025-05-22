using CSV
using DataFrames
using Statistics

# 📂 Cargar el archivo
df = CSV.read("banco_cuentas.csv", DataFrame)

# 🧪 Crear columnas de condiciones
df.saldo_bajo = df.Saldo .< 2000
df.seguro_alto = df."Saldo de Seguro Pendiente" .> 3000
df.cuenta_corriente = df."Tipo de Cuenta" .== "Corriente"
df.condiciones_cumplidas = df.saldo_bajo .+ df.seguro_alto .+ df.cuenta_corriente
df.en_riesgo = df.condiciones_cumplidas .>= 2

# 🗂️ Subconjunto con cuentas en riesgo
riesgo_df = df[df.en_riesgo .== true, :]

function mostrar_menu()
    println("\n🧮 MENÚ DE OPCIONES:")
    println("1️⃣  Mostrar estadísticas generales")
    println("2️⃣  Buscar cuenta por ID de Cliente")
    println("3️⃣  Guardar cuentas en riesgo en CSV")
    println("0️⃣  Salir")
end

function mostrar_estadisticas()
    cuentas_en_riesgo = nrow(riesgo_df)
    total_cuentas = nrow(df)
    porcentaje_riesgo = 100 * cuentas_en_riesgo / total_cuentas
    saldo_promedio_riesgo = mean(riesgo_df.Saldo)
    
    tipo_comun = combine(groupby(riesgo_df, "Tipo de Cuenta"), nrow => :Cuenta)
    
    # Ordenar correctamente por número de cuentas en riesgo
    tipo_comun = sort(tipo_comun, :Cuenta, rev=true)  # Usar sort en lugar de sort!
    
    println("\n🔎 ESTADÍSTICAS GENERALES:")
    println("Cuentas en riesgo: $cuentas_en_riesgo")
    println("Porcentaje en riesgo: $(round(porcentaje_riesgo, digits=2))%")
    println("Saldo promedio (en riesgo): \$$(round(saldo_promedio_riesgo, digits=2))")
    println("Tipo de cuenta más común en riesgo: ", tipo_comun[1, "Tipo de Cuenta"])
end

function buscar_cliente()
    print("\n🔍 Ingresa el ID del cliente: ")
    id = readline()
    fila = df[df."ID del Cliente" .== id, :]
    
    if nrow(fila) == 0
        println("❌ No se encontró un cliente con ese ID.")
    else
        es_riesgo = fila[1, :en_riesgo]
        println("\n📄 Resultado para cliente ID=$id:")
        println("Tipo de cuenta: ", fila[1, "Tipo de Cuenta"])
        println("Saldo: \$", fila[1, :Saldo])
        println("Saldo de seguro pendiente: \$", fila[1, "Saldo de Seguro Pendiente"])
        println("¿En riesgo?: ", es_riesgo ? "✅ Sí" : "🟢 No")
        println("Condiciones cumplidas: ", fila[1, :condiciones_cumplidas], " de 3")
    end
end

function guardar_csv()
    CSV.write("cuentas_en_riesgo.csv", riesgo_df)
    println("✅ Archivo 'cuentas_en_riesgo.csv' guardado con éxito.")
end

# 🧭 Loop del menú
while true
    mostrar_menu()
    print("\nElige una opción: ")
    opcion = readline()

    if opcion == "1"
        mostrar_estadisticas()
    elseif opcion == "2"
        buscar_cliente()
    elseif opcion == "3"
        guardar_csv()
    elseif opcion == "0"
        println("👋 Saliendo del programa. ¡Hasta luego!")
        break
    else
        println("⚠️ Opción no válida. Intenta de nuevo.")
    end
end
