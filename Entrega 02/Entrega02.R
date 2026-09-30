
# ===============================================================================
# UNIVERSIDAD DE CHILE - FACULTAD DE ECONOMÍA Y NEGOCIOS
# Diploma en Ciencia de Datos para las Finanzas
# Módulo: Finanzas en R - Profesor Sebastian Egaña

# PROYECTO FINAL
# Autor: Felipe Zúñiga
# Octubre 2026
# ===============================================================================

# MODELO DE FOCALIZACIÓN DE REVISIÓN PARA CARTERA COMERCIAL MAYORISTA A4-A6

# Construye una fila de espera priorizada de revisión para una cartera de 137
# deudores comerciales evaluados individualmente, a partir de su comportamiento
# de pago histórico y del impacto en provisiones de una eventual migración de
# categoría.

# -------------------------------------------------------------------------------
# 1. PROBLEMA QUE RESUELVE
# -------------------------------------------------------------------------------
# En banca mayorista el seguimiento de riesgo se realiza cliente por cliente. El
# analista dispone de tiempo limitado y de una cartera que excede su capacidad de
# revisión exhaustiva, por lo que debe decidir a quién mirar primero.

# La clasificación normativa ya incorpora el riesgo de cada deudor, pero dentro de
# un mismo tramo conviven comportamientos de pago muy distintos. Un deudor A4 que
# se comporta como un A6 constituye una inconsistencia entre conducta observada y
# categoría vigente, y es ese caso el que conviene revisar primero.

# El foco se restringe a A4-A6: en A1-A3 el riesgo no obedece principalmente a
# comportamiento de pago, mientras que en cartera subestándar (B) y en
# incumplimiento (C) el deudor ya está bajo seguimiento intensivo y la provisión
# ya recoge el deterioro. A4-A6 es la zona de frontera, donde cada escalón de
# migración tiene un costo material.

# EL MODELO NO RECLASIFICA. ORDENA.
# La decisión de reclasificar sigue siendo del analista.

# El insumo principal es un informe semanal de mora que hoy se recibe cada lunes
# con corte al viernes anterior, por semana y no acumulado. Al no almacenarse, la
# trayectoria se pierde. Este programa reconstruye esa serie histórica, que hoy no
# existe en el proceso.

# -------------------------------------------------------------------------------
# 2. DATOS SINTÉTICOS (declaración explícita)
# -------------------------------------------------------------------------------
# Por confidencialidad, la totalidad de los datos es ficticia y generada por
# simulación con semilla fija, lo que garantiza reproducibilidad. No se utiliza información
# real de clientes.

# Las probabilidades de pago semanal fueron calibradas por simulación de modo que
# la frecuencia de deudores que alcanzan 90 días de mora se aproxime a las
# probabilidades de incumplimiento normativas de cada categoría (A4: 2,00%;
# A5: 4,75%; A6: 10,00%). El comportamiento no fue inventado: se ajustó contra la
# norma.

# Verificación de la calibración: la configuración final del generador -que
# incorpora el desfase del vencimiento respecto del cierre de mes y la dispersión
# de probabilidades entre deudores de una misma categoría- produce PI observadas
# de 2,53%, 5,80% y 12,57% para A4, A5 y A6 respectivamente. El sesgo al alza es
# del orden del 25% en las tres categorías y responde a la convexidad de la
# relación entre probabilidad semanal de pago y probabilidad anual de alcanzar
# 90 días de mora. Al ser un sesgo de escala aproximadamente uniforme, preserva el
# ordenamiento relativo entre categorías, que es lo que el modelo utiliza.

# -------------------------------------------------------------------------------
# 3. LÓGICA DEL MODELO
# -------------------------------------------------------------------------------
#     Prioridad = brecha de conducta (0 a 1) x provisión en riesgo (MM$)

#   - Brecha de conducta: residuo de una regresión que explica el comportamiento
#     de pago observado a partir de la categoría vigente. Un residuo positivo
#     indica que el deudor se comporta peor que sus pares de igual clasificación.
#     Los residuos negativos se truncan en cero: comportarse mejor que lo esperado
#     no es motivo de revisión.

#   - Provisión en riesgo: diferencia entre la provisión constituida bajo la
#     categoría vigente y la que correspondería ante una migración de un escalón,
#     según la tabla de pérdida esperada del Capítulo B-1 del Compendio de Normas
#     Contables (PE = PI x PDI).

# Al multiplicar un factor entre 0 y 1 por un monto en pesos, el resultado se
# mantiene en pesos y se lee como: de la provisión que este deudor tiene en
# riesgo, qué parte está respaldada por una conducta anómala.

# ADVERTENCIA DE INTERPRETACIÓN: el índice de prioridad ordena, no cuantifica. No
# es una provisión esperada, porque la brecha no es una probabilidad de migración.
# Estimar esa probabilidad requeriría un modelo predictivo, expresamente fuera del
# alcance de este trabajo.

# -------------------------------------------------------------------------------
# 4. RESULTADOS DE APRENDIZAJE CUBIERTOS (5 de 6)
# -------------------------------------------------------------------------------
#   RA1  Contexto de R en el ecosistema ....... sección 5 de este encabezado
#   RA2  Objetos y tratamiento de datos ............ celdas 2 a 6
#   RA3  Operaciones matemáticas en finanzas ....... celda 7
#   RA4  Herramientas estadísticas ................. celda 8
#   RA5  Econometría básica ........................ celda 8

# -------------------------------------------------------------------------------
# 5. POR QUÉ R Y NO UNA PLANILLA (RA1)
# -------------------------------------------------------------------------------
#   - Simulación reproducible: 137 series de 52 semanas (7.124 observaciones)
#     generadas con semilla fija. En planilla exigiría igual número de celdas con
#     fórmulas volátiles, sin trazabilidad.
#   - Calibración iterativa: ajustar las probabilidades contra las PI normativas
#     requirió correr decenas de miles de simulaciones por cada valor candidato.
#     Inviable en planilla.
#   - Econometría integrada: lm() entrega coeficientes, significancia y
#     residuos sobre la misma base, sin exportar ni pegar entre herramientas.
#   - Parametrización: cambiar el tamaño de la cartera, el umbral de
#     incumplimiento o los pesos de cronicidad es modificar una línea y volver a
#     ejecutar.
#   - Auditabilidad: el proceso completo queda en un archivo de texto legible y
#     versionable. Las decisiones de modelamiento son explícitas, no están
#     escondidas dentro de celdas.

# R reúne en un mismo entorno la simulación, el manejo de datos, la econometría
# (nativa, sin librerías adicionales) y la salida a Excel, que es el formato en
# que el resultado se consume operativamente. Las dependencias quedan fijadas
# con renv, de modo que cualquier persona puede reproducir el resultado exacto.

# -------------------------------------------------------------------------------
# 6. PRINCIPALES RESULTADOS
# -------------------------------------------------------------------------------
#   - Cartera simulada: 137 deudores, 107.671 MM$ de exposición
#   - Provisión constituida: 7.356 MM$ | Provisión en riesgo: 4.982 MM$
#   - 12 deudores A4/A5 con EEFF desactualizados (7.666 MM$ de exposición):
#     incumplen el techo normativo A6 por control administrativo, sin necesidad
#     de análisis de riesgo
#   - Regresión conducta ~ categoría: R2 = 0,014 (p = 0,164). La categoría vigente
#     explica apenas el 1,4% de la variación en comportamiento de pago; el 98,6%
#     restante ocurre DENTRO de las categorías. Este resultado no es una debilidad
#     del modelo: es su justificación. Si la clasificación explicara la conducta,
#     bastaría con revisar en orden de categoría.
#   - Comparación contra el criterio actual: de los 5 deudores con mayor provisión
#     en riesgo (criterio de tamaño), 2 presentan brecha de conducta nula. Bajo el
#     criterio vigente serían de las primeras carpetas abiertas sin que exista
#     señal que lo justifique.

# -------------------------------------------------------------------------------
# 7. SUPUESTOS Y LIMITACIONES
# -------------------------------------------------------------------------------
#   Sobre la simulación
#   - Vencimiento mensual aproximado a 4 semanas: genera 13 ciclos al año en vez
#     de 12.
#   - Vencimiento situado en la primera quincena, desfasado del cierre de mes,
#     replicando el calendario habitual de la cartera.
#   - Pago total o nulo: no se modelan abonos parciales, que en la práctica
#     reducen la mora sin llevarla a cero.
#   - La dispersión introducida en las probabilidades de pago sesga al alza la
#     frecuencia de incumplimientos, por la no linealidad entre probabilidad
#     semanal de pago y probabilidad anual de alcanzar 90 días.
#   - No se consideran garantías: la exposición se toma íntegra como afecta a
#     provisiones (EAP), lo que sobreestima la provisión en riesgo de deudores
#     con cobertura real.

#   Sobre los datos
#   - La observación semanal solo captura la mora vigente cada viernes. Un deudor
#     que entra y regulariza entre dos cortes resulta invisible.
#   - Los estados de cierre mensual se derivan de la serie semanal y no se generan
#     de forma independiente, para evitar inconsistencias entre ambas fuentes.

#   Sobre el modelo
#   - Con 137 observaciones la regresión no alcanza significancia estadística
#     convencional. Es una restricción del universo, no del método: la banca
#     mayorista tiene pocos deudores por definición. Como verificación, se replicó
#     el ejercicio ampliando la cartera a las seis categorías de cartera normal
#     (calibrando A1: 0,520; A2: 0,500; A3: 0,455 contra sus respectivas PI),
#     obteniendo R2 = 0,25 con relación significativa. La extensión es directa y
#     queda propuesta como continuación.
#   - La normalización de la brecha es relativa al máximo de la cartera vigente,
#     por lo que los puntajes no son comparables entre períodos distintos.
#   - Los umbrales de la columna de justificación son criterio experto, no
#     estimaciones.

# -------------------------------------------------------------------------------
# 8. SALIDAS
# -------------------------------------------------------------------------------
#   Archivos generados en el directorio de trabajo:
#       resultado_focalizacion.xlsx
#           Hoja "Fila de espera" : 137 deudores ordenados por índice de
#                                   prioridad, con columna de justificación
#           Hoja "Control EEFF"   : deudores A4/A5 con estados financieros
#                                   vencidos
#       grafico1_trayectoria.png  : trayectoria de mora del deudor prioritario
#       grafico2_dispersion.png   : brecha de conducta vs. provisión en riesgo

# ===============================================================================
# PRINCIPIOS DE DISEÑO APLICADOS
#   "Explícito es mejor que implícito"  -> todos los parámetros están declarados
#      con nombre en la celda 2; no hay constantes numéricas dentro de la lógica.
#   "Simple es mejor que complejo"      -> dos indicadores de comportamiento en
#      lugar de un score multivariado difícil de auditar.
#   "La legibilidad cuenta"             -> nombres de columnas autoexplicativos.
#   "Los casos especiales no son tan especiales como para quebrantar las reglas"
#      -> el control de EEFF opera como regla normativa separada, no como un
#      término más dentro del puntaje.
# ===============================================================================

# %%

# %% CELDA 1 - LIBRERÍAS
library(ggplot2)

# %% CELDA 2 - PARÁMETROS
# =============================================================================
# Todos los supuestos del modelo viven acá. Para probar otro escenario basta
# modificar esta celda y volver a ejecutar el archivo completo.
# =============================================================================

# --- Reproducibilidad ---
set.seed(42)

# --- Horizonte de simulación ---
semanas <- 52                    # un año de cortes semanales (viernes)
meses <- 12                      # un año de cierres mensuales
cada_cuantas_vence <- 4          # vencimiento mensual aproximado a 4 semanas
semana_del_vencimiento <- 2      # vence a mitad de mes, desfasado del cierre
dias_por_semana <- 7             # incremento del contador entre dos viernes
dias_incumplimiento <- 90        # umbral normativo de cartera en incumplimiento

# --- Comportamiento de pago por categoría ---
# Probabilidad de REGULARIZAR en una semana dada, estando ya en mora.
# No es la probabilidad de pagar en general: un A4 pasa la mayor parte del año
# en cero y solo cuando cae tarda en salir.
# Calibrada por simulación contra las PI del Capítulo B-1 (ver encabezado).
prob_por_categoria <- c(A4 = 0.355, A5 = 0.310, A6 = 0.262)
dispersion_prob <- 0.035         # dentro de una categoría no todos se comportan igual
prob_minima <- 0.05              # cotas de seguridad: una probabilidad
prob_maxima <- 0.95              # nunca puede salir de [0, 1]

# Calibración extendida, no usada en el modelo base (ver encabezado, sección 7):
# A1: 0.520 | A2: 0.500 | A3: 0.455

# --- Composición de la cartera ---
conteo_cartera <- c(A4 = 11, A5 = 46, A6 = 80)
mediana_exposicion <- 600        # millones de pesos
sigma_exposicion <- 0.9          # dispersión; genera la cola larga a la derecha
prop_eeff_vencidos <- 0.15       # 15% de la cartera con EEFF desactualizados
sectores <- c("Comercio", "Construcción", "Industria", "Agro",
            "Servicios", "Transporte")

# --- Ponderación de la cronicidad ---
gravedad <- c(O = 0, I = 1, V = 3)   # V pesa como tres impagos (criterio experto)
peso_mes_antiguo <- 0.5                # el mes más viejo pesa la mitad
peso_mes_reciente <- 1.5               # el más reciente, una vez y media

# --- Pérdida esperada = PI x PDI (Capítulo B-1, método estándar CMF) ---
pe_por_categoria <- c(
    A4 = 0.017500,   # 2,00%  x 87,5%
    A5 = 0.042750,   # 4,75%  x 90,0%
    A6 = 0.090000,   # 10,00% x 90,0%
    B1 = 0.138750   # 15,00% x 92,5%  (destino de migración de un A6)
)

# A qué categoría migra cada deudor si baja un escalón
migracion <- c(A4 = "A5", A5 = "A6", A6 = "B1")

# --- Umbrales de la columna de justificación (criterio experto) ---
umbral_severidad <- 30           # días de mora en el último corte
umbral_cronicidad <- 8           # puntaje ponderado de cierres mensuales
umbral_residuo <- 1              # desviación respecto de los pares

# %% CELDA 3 - PARTE 1.1: SERIE SEMANAL DE MORA
# =============================================================================
# Simula, para cada deudor, 52 cortes de viernes con días de mora.
#
# Mecánica del contador (diente de sierra):
#   - vale 0 mientras no exista cuota vencida impaga
#   - se activa al vencer una cuota que no se paga
#   - entre viernes consecutivos sube exactamente +7 si no hubo abono
#   - vuelve a 0 al pagar, y sigue en 0 hasta el próximo vencimiento
# El cero es el estado NORMAL, no el estado bueno.
# =============================================================================

# La cartera se arma repitiendo cada categoría según su conteo
categorias <- c()
for (categoria in names(conteo_cartera)) {
    categorias <- c(categorias, rep(categoria, conteo_cartera[[categoria]]))
}

todas_las_series <- list()            # nombre del deudor -> su serie de 52 semanas
categoria_por_cliente <- character()  # nombre del deudor -> su categoría vigente

for (i in seq_along(categorias)) {
    categoria <- categorias[i]
    nombre <- sprintf("CLI_%03d", i)   # CLI_001, CLI_002, ... CLI_137

    # Cada deudor recibe una probabilidad propia alrededor de la calibrada
    # para su categoría. Sin esta dispersión todos se comportarían igual y
    # el modelo no tendría anomalías que detectar.
    prob_pago <- rnorm(1, prob_por_categoria[[categoria]], sd = dispersion_prob)
    prob_pago <- min(max(prob_pago, prob_minima), prob_maxima)

    mora <- 0         # contador de días; parte al día
    serie <- c()      # acumula los 52 valores de este deudor

    for (semana in seq_len(semanas)) {

        # Moneda cargada: sale TRUE con probabilidad prob_pago
        pago <- rbinom(1, size = 1, prob = prob_pago) == 1

        if (mora > 0) {                         # CASO A: venía en mora
            if (pago) {
                mora <- 0                       # regularizó: el contador se reinicia
            } else {
                mora <- mora + dias_por_semana  # nadie abonó: pasaron 7 días
            }
        } else {                                # CASO B: venía al día
            # El módulo convierte el contador de semanas en un evento
            # periódico: es verdadero en las semanas 2, 6, 10, 14...
            vence <- (semana %% cada_cuantas_vence == semana_del_vencimiento)
            if (vence && !pago) {
                # Arranca entre 1 y 7 días según el día en que cayó el
                # vencimiento dentro de la semana (sample toma uno de 1:7)
                mora <- sample(1:dias_por_semana, 1)
            }
        }

        serie <- c(serie, mora)
    }   # fin loop semanas

    todas_las_series[[nombre]] <- serie
    categoria_por_cliente[[nombre]] <- categoria
}   # fin loop deudores
# Cada elemento de la lista se convierte en una columna: 52 filas x 137 columnas
base_mora <- as.data.frame(todas_las_series)

#%% CELDA 4 - PARTE 1.2: ESTADO DE CIERRE MENSUAL (O / I / V)
# =============================================================================
# Traduce la serie semanal a los 12 estados de cierre de mes.
#
# Se derivan de la serie semanal y no se generan aparte: en el sistema de
# origen ambos informes salen de la misma cartera, así que sortearlos por
# separado produciría contradicciones (un cierre "O" en un mes con 30 días
# de mora en la serie).
# =============================================================================

# Glosario de los estados, ordenados por gravedad creciente
estados_def <- c(O = "Operativo", I = "Impago", V = "Vencido")

estados <- list()

for (cada_cliente in names(base_mora)) {

    lista_estados <- c()

    for (mes in seq_len(meses)) {

        # El cierre de cada mes cae en la última semana del bloque
        semana_cierre <- mes * cada_cuantas_vence
        mora_cierre <- base_mora[semana_cierre, cada_cliente]

        # El orden de las preguntas importa: la más específica va primero.
        # Si se preguntara por "mayor que cero" antes que por el umbral de
        # incumplimiento, ningún caso llegaría a clasificarse como "V".
        if (mora_cierre == 0) {
            estado <- "O"
        } else if (mora_cierre >= dias_incumplimiento) {
            estado <- "V"
        } else {
            estado <- "I"
        } 
        lista_estados <- c(lista_estados, estado)
    }
    # Se guarda al terminar los 12 meses, no dentro del loop mensual
    estados[[cada_cliente]] <- lista_estados
}
base_estado <- as.data.frame(estados)

#%% CELDA 5 - PARTE 1.3: CARTERA BASE
# =============================================================================
# Atributos de cada deudor. A diferencia de las dos tablas anteriores, esta
# no tiene dimensión temporal: es una foto.
# =============================================================================

n_clientes <- length(categorias)

base_clientes <- data.frame(
    Categoria = categorias,

    # Sorteo simple entre los sectores definidos
    Sector = sample(sectores, n_clientes, replace = TRUE),

    # Lognormal y no normal: reproduce la concentración típica de una cartera
    # mayorista, donde unos pocos deudores acumulan buena parte de la
    # exposición. Es esa asimetría la que hace que ponderar por provisión en
    # riesgo cambie efectivamente el orden de la fila de espera.
    Exposicion = round(rlnorm(n_clientes, meanlog = log(mediana_exposicion),

                              sdlog = sigma_exposicion), 0),
    # Comparar un aleatorio contra un umbral produce el porcentaje buscado
    EEFF_vigentes = runif(n_clientes) > prop_eeff_vencidos,
    row.names = names(base_mora)
)

#%% CELDA 6 - PARTE 2: INDICADORES DE COMPORTAMIENTO
# =============================================================================
# Dos indicadores, no diez. Con 137 deudores un score de muchas variables es
# imposible de auditar y nadie confía en él. La correlación entre ambos es
# baja (0,16), de modo que no son redundantes: miden cosas distintas.
# =============================================================================

# --- Severidad: qué tan profunda es la mora HOY ---
severidad <- unlist(base_mora[semanas, ])      # fila 52 = último corte disponible

# --- Cronicidad: qué tan repetitivo es el problema ---
# Las letras no se pueden sumar, así que primero se traducen a números:
# cada estado O / I / V se reemplaza por su peso en el vector gravedad.
base_num <- sapply(base_estado, function(columna) unname(gravedad[columna]))

# Tres tropiezos recientes no son lo mismo que tres de hace un año.
# Los pesos se reparten parejo entre 0,5 y 1,5; el promedio es 1,
# así que la ponderación no distorsiona la escala.
pesos <- seq(peso_mes_antiguo, peso_mes_reciente, length.out = meses)

# Cada FILA (mes) se multiplica por su peso; colSums() suma hacia abajo
# y deja un número por deudor.
cronicidad <- colSums(pesos * base_num)

indicadores <- data.frame(
    Severidad = severidad,
    Cronicidad = cronicidad
)


#%% CELDA 7 - PARTE 3: PROVISIONES (CAPÍTULO B-1)
# =============================================================================
# Cuantifica el costo en pesos de una eventual migración de un escalón.
# =============================================================================

# Indexar un vector con nombres traduce cada categoría a su pérdida esperada
base_clientes$PE_actual <- unname(pe_por_categoria[base_clientes$Categoria])
base_clientes$Provision_actual <- base_clientes$Exposicion * base_clientes$PE_actual

# Dos traducciones encadenadas: primero a qué categoría migra, y recién con
# esa categoría en mano se busca su pérdida esperada.
base_clientes$Categoria_migrada <- unname(migracion[base_clientes$Categoria])
base_clientes$PE_migrada <- unname(pe_por_categoria[base_clientes$Categoria_migrada])
base_clientes$Provision_migrada <-  base_clientes$Exposicion * base_clientes$PE_migrada

# Provisión en riesgo: cuántos millones adicionales habría que constituir
base_clientes$Provision_riesgo <- base_clientes$Provision_migrada -
                                  base_clientes$Provision_actual