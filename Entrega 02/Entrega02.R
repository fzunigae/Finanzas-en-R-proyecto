
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
#     de pago observado a partir de la categoría vigente, ingresada como
#     variable categórica (factor). Así el valor esperado de cada deudor es el
#     promedio de conducta de su categoría, sin suponer que los saltos entre
#     A4, A5 y A6 son iguales. Un residuo positivo indica que el deudor se
#     comporta peor que el promedio de sus pares de igual clasificación.
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
#   - Cartera simulada: 137 deudores, 138.531 MM$ de exposición
#   - Provisión constituida: 9.722 MM$ | Provisión en riesgo: 6.489 MM$
#   - 8 deudores A4/A5 con EEFF desactualizados (5.040 MM$ de exposición):
#     incumplen el techo normativo A6 por control administrativo, sin necesidad
#     de análisis de riesgo
#   - Regresión conducta ~ categoría (factor): R2 = 0,142 (p < 0,001). La
#     relación es significativa, pero la categoría vigente explica apenas el
#     14,2% de la variación en comportamiento de pago; el 85,8% restante
#     ocurre DENTRO de las categorías. Este resultado no es una debilidad del
#     modelo: es su justificación. Si la clasificación explicara la conducta,
#     bastaría con revisar en orden de categoría.
#   - Mejora respecto de la versión 1 (categoría como número 4/5/6, R2 = 0,102):
#     el test F entre ambos modelos anidados rechaza el supuesto de saltos
#     iguales entre categorías (p = 0,014). En esta cartera los A5 muestran en
#     promedio mejor conducta que los A4, algo que una recta no puede
#     representar: en la versión 1 el residuo promedio era +0,76 en A4 y
#     -0,36 en A5 (en vez de 0), es decir, los A4 parecían peores que sus
#     pares y los A5 mejores, solo por la forma del modelo. El efecto
#     práctico es acotado: 9 de los 10 primeros de la fila de espera se
#     mantienen; sale CLI_004 (A4) y entra CLI_070 (A5), en la dirección
#     predicha. El deudor prioritario (CLI_081) no cambia.
#   - Comparación contra el criterio actual: de los 5 deudores con mayor provisión
#     en riesgo (criterio de tamaño), 3 presentan brecha de conducta nula. Bajo el
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
#   - Con 137 observaciones y solo tres categorías, la regresión tiene poca
#     variación en la variable explicativa. Es una restricción del universo, no
#     del método: la banca mayorista tiene pocos deudores por definición. La
#     extensión a las seis categorías de cartera normal (calibrando A1: 0,520;
#     A2: 0,500; A3: 0,455 contra sus respectivas PI) es directa y queda
#     propuesta como continuación.
#   - Con solo 11 deudores A4, el promedio de conducta que sirve de referencia
#     para esa categoría se estima con poca precisión. La inversión observada
#     entre A4 y A5 es atribuible a ese ruido muestral: en el generador las
#     probabilidades de pago son monótonas por categoría.
#   - Los resultados dependen de la semilla: otra semilla produce otra cartera
#     simulada y, por lo tanto, otras cifras en la sección 6.
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

#%% CELDA 1 - LIBRERÍAS
library(ggplot2)
library(writexl)

#%% CELDA 2 - PARÁMETROS
# =============================================================================
# Todos los supuestos del modelo viven acá. Para probar otro escenario basta
# modificar esta celda y volver a ejecutar el archivo completo.
# =============================================================================

# --- Reproducibilidad ---
set.seed(42)

# --- Salidas ---
# Ruta relativa a la raíz del proyecto (Proyecto Final R/), que es el
# directorio de trabajo en el que renv queda activo.
carpeta_salida <- "Entrega 02"

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

#%% CELDA 3 - PARTE 1.1: SERIE SEMANAL DE MORA
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
# baja (0,23), de modo que no son redundantes: miden cosas distintas.
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

#%% CELDA 8 - PARTE 4: ESTADÍSTICA Y REGRESIÓN
# =============================================================================
# La regresión explica la CONDUCTA a partir de la CATEGORÍA, y no al revés.
# Así el valor ajustado es "cuánta mora se espera de un deudor de esta
# clasificación", y el residuo mide cuánto se aparta de sus propios pares.
# La comparación contra pares de igual categoría queda incorporada en la
# regresión misma.
#
# El modelo es descriptivo, no predictivo: caracteriza la relación existente
# en la cartera observada, no anticipa eventos futuros.
# =============================================================================

# Ambas tablas usan los códigos de deudor como nombres de fila y en el mismo
# orden; se verifica antes de pegarlas columna a columna.
stopifnot(identical(rownames(base_clientes), rownames(indicadores)))
datos <- cbind(base_clientes, indicadores)
datos$Categoria_num <- unname(c(A4 = 4, A5 = 5, A6 = 6)[datos$Categoria])

# --- 4.1 Estadística descriptiva ---
vars <- c("Severidad", "Cronicidad", "Exposicion", "Provision_riesgo")
describir <- function(x) c(n = length(x), media = mean(x), desv = sd(x), quantile(x))
print(round(sapply(datos[vars], describir), 2))
print(aggregate(cbind(Severidad, Cronicidad) ~ Categoria, data = datos,
                FUN = function(x) round(describir(x), 2)))

# --- 4.2 Matriz de correlaciones ---
# Verifica si los indicadores aportan información independiente.
# Exposición vs. Provisión en riesgo da 0,99: priorizar por provisión en
# riesgo es casi priorizar por tamaño. Cronicidad vs. Exposición da 0,09:
# la conducta casi no tiene relación con el tamaño, y por eso multiplicarlas
# genera información en vez de reforzar un mismo eje.
print(round(cor(datos[vars]), 3))

# --- Índice de conducta ---
# Severidad llega a 102 y cronicidad a 17,7. Sin estandarizar, la primera
# aplastaría a la segunda solo por tener otra escala.
# scale() devuelve una matriz; as.numeric() la deja como vector.
datos$Conducta <- as.numeric(scale(datos$Severidad)) + as.numeric(scale(datos$Cronicidad))

# --- 4.3 Regresión por mínimos cuadrados ordinarios ---
# La categoría entra como FACTOR y no como número (4, 5, 6). Como número,
# el modelo ajusta una sola pendiente y supone que el salto de conducta
# A4 -> A5 es igual al de A5 -> A6, sin haberlo verificado. Como factor,
# R crea una dummy por categoría (A4 queda como base) y cada una tiene su
# propio nivel: el valor ajustado pasa a ser el promedio de sus pares.
# Equivale en Python a smf.ols("Conducta ~ C(Categoria)", data=datos).
modelo <- lm(Conducta ~ factor(Categoria), data = datos)
print(summary(modelo))

# --- 4.4 Comparación contra la versión lineal (v1) ---
# El modelo lineal es un caso particular del factorial: el factorial
# nunca ajusta peor. anova() con dos modelos anidados hace un test F de
# si la restricción de "saltos iguales" es aceptable. Un p-valor alto
# indica que imponerla no cuesta ajuste; uno bajo, que la v1 distorsionaba
# los residuos.
modelo_lineal <- lm(Conducta ~ Categoria_num, data = datos)
cat("R2 lineal: ", round(summary(modelo_lineal)$r.squared, 3), "\n")
cat("R2 factor: ", round(summary(modelo)$r.squared, 3), "\n")
print(anova(modelo_lineal, modelo))

# --- 4.5 Residuos ---
# Valor ajustado = conducta promedio de la categoría del deudor.
# Residuo = cuánto se aparta el deudor del promedio de sus pares.
datos$Conducta_esperada <- fitted(modelo)
datos$Residuo <- resid(modelo)

# Verificación: con solo dummies de categoría, MCO ajusta a cada grupo su
# media, porque la media es el valor que minimiza la suma de cuadrados.
# Si eso no se cumple, algo está mal en la especificación y se detiene.
promedios <- aggregate(cbind(Conducta, Conducta_esperada) ~ Categoria,
                       data = datos, FUN = mean)
print(promedios)
stopifnot(isTRUE(all.equal(promedios$Conducta, promedios$Conducta_esperada)))

#%% CELDA 9 - PARTE 5: ÍNDICE DE PRIORIDAD Y FILA DE ESPERA
# =============================================================================
# Prioridad = brecha de conducta (0 a 1) x provisión en riesgo (MM$)
# =============================================================================

# Un residuo negativo significa que el deudor se comporta MEJOR que sus pares.
# Eso no es riesgo, así que la brecha solo cuenta hacia arriba.
datos$Brecha <- pmax(datos$Residuo, 0)

# Al normalizar a escala 0-1 antes de multiplicar, el resultado se mantiene
# en millones de pesos y se lee como: de la provisión que este deudor tiene
# en riesgo, qué parte está respaldada por una conducta anómala.
datos$Brecha_Norm <- datos$Brecha / max(datos$Brecha)
datos$Prioridad <- datos$Brecha_Norm * datos$Provision_riesgo

# Devuelve el texto que explica por qué un deudor está donde está en la fila.
# Sin esta columna el modelo es una caja negra y ningún analista le hace
# caso. Los umbrales son criterio experto, no estimaciones.
#   fila:    una fila de datos (data.frame de una fila)
#   retorna: motivos separados por " / ", o "sin alertas" si no gatilla ninguno
justificar <- function(fila) {
    motivos <- character()
    if (fila$Severidad >= umbral_severidad) {
        motivos <- c(motivos, "mora actual alta")
    }
    if (fila$Cronicidad >= umbral_cronicidad) {
        motivos <- c(motivos, "mora recurrente")
    }
    if (fila$Residuo >= umbral_residuo) {
        motivos <- c(motivos, "conducta peor que sus pares")
    }
    if (!fila$EEFF_vigentes) {
        motivos <- c(motivos, "EEFF desactualizados")
    }
    if (length(motivos) == 0) {
        return("sin alertas")
    }
    paste(motivos, collapse = " / ")
}

# sapply() recorre los números de fila y le pasa a la función cada fila completa
datos$Justificacion <- sapply(seq_len(nrow(datos)),
                              function(i) justificar(datos[i, ]))

# Columnas que van al Excel: se define una sola vez y se reutiliza
columnas_salida <- c(
    "Categoria", "Sector", "Exposicion", "EEFF_vigentes",
    "Severidad", "Cronicidad", "Residuo",
    "Provision_actual", "Provision_riesgo", "Prioridad", "Justificacion"
)

# --- Control normativo de EEFF ---
# No es un indicador que suma puntaje: es una regla. Un deudor A4 o A5 con
# estados financieros desactualizados no puede clasificarse mejor que A6, y
# eso se verifica sin necesidad de análisis de riesgo.
control_eeff <- datos[datos$Categoria %in% c("A4", "A5") & !datos$EEFF_vigentes,
                      columnas_salida]

# --- Fila de espera ---
fila_espera <- datos[order(datos$Prioridad, decreasing = TRUE), columnas_salida]

# --- Efecto del cambio sobre la fila de espera ---
# Se reconstruye la prioridad de la v1 con los residuos del modelo lineal
# para medir cuánto cambia el orden.
brecha_v1 <- pmax(resid(modelo_lineal), 0)
prioridad_v1 <- brecha_v1 / max(brecha_v1) * datos$Provision_riesgo
top10_v1 <- rownames(datos)[order(prioridad_v1, decreasing = TRUE)][1:10]
top10_v2 <- rownames(fila_espera)[1:10]
cat("Coinciden en el top-10:", length(intersect(top10_v1, top10_v2)), "de 10\n")
cat("Salen:  ", setdiff(top10_v1, top10_v2), "\n")
cat("Entran: ", setdiff(top10_v2, top10_v1), "\n")

#%% CELDA 10 - VISUALIZACIONES
# ---------- Gráfico 1: trayectoria del deudor prioritario ----------
# which.max() devuelve la POSICIÓN del valor más alto, no el valor;
# con esa posición se obtiene el nombre de fila: entrega quién, no cuánto.
cliente_top <- rownames(datos)[which.max(datos$Prioridad)]

# ggplot trabaja sobre un data.frame: se arma uno con la serie del deudor
trayectoria <- data.frame(
    Semana = seq_len(semanas),
    Mora = base_mora[[cliente_top]]
)

# El gráfico se construye por capas que se suman con +
# La línea del umbral hace visible el límite normativo: se ve de inmediato
# qué tan cerca está el deudor de cruzar a cartera en incumplimiento.
grafico1 <- ggplot(trayectoria, aes(x = Semana, y = Mora)) +
    geom_area(fill = "steelblue", alpha = 0.15) +
    geom_line(color = "steelblue") +
    geom_point(color = "steelblue", size = 1.5) +
    geom_hline(yintercept = dias_incumplimiento, color = "red",
               linetype = "dashed", linewidth = 0.6) +
    annotate("text", x = 1, y = dias_incumplimiento,
             label = paste0("Umbral de incumplimiento (",
                            dias_incumplimiento, " días)"),
             color = "red", hjust = 0, vjust = -0.5, size = 3.5) +
    labs(title = paste0("Trayectoria de mora del deudor prioritario: ",
                        cliente_top, " (", datos[cliente_top, "Categoria"], ")"),
         x = "Semana del año", y = "Días de mora") +
    theme_bw()

print(grafico1)
ggsave(file.path(carpeta_salida, "grafico1_trayectoria.png"), grafico1, width = 11, height = 4.5, dpi = 150)

# ---------- Gráfico 2: brecha de conducta vs. provisión en riesgo ----------
# Las dos líneas punteadas parten el plano en cuatro cuadrantes:
#   arriba a la derecha -> mucha plata y conducta anómala: revisar primero
#   arriba a la izquierda -> mucha plata sin señal: los que el criterio de
#                            tamaño pondría primero y este modelo descarta
colores <- c(A4 = "#2E7D32", A5 = "#EF6C00", A6 = "#C62828")

# Se etiquetan los cuatro primeros de la fila de espera
top4 <- datos[rownames(fila_espera)[1:4], ]

# Al mapear fill a Categoria, ggplot colorea por grupo y arma la leyenda solo.
# shape = 21 es un círculo con relleno y borde, lo que permite el borde blanco.
grafico2 <- ggplot(datos, aes(x = Brecha_Norm, y = Provision_riesgo,
                              fill = Categoria)) +
    geom_point(shape = 21, color = "white", size = 3, alpha = 0.75) +
    geom_text(data = top4, aes(label = rownames(top4)),
              hjust = 0, nudge_x = 0.015, nudge_y = 8, size = 3) +
    geom_vline(xintercept = 0.5, color = "gray", linetype = "dotted") +
    geom_hline(yintercept = median(datos$Provision_riesgo), color = "gray",
               linetype = "dotted") +
    scale_fill_manual(values = colores) +
    labs(title = "Brecha de conducta vs. provisión en riesgo",
         x = "Brecha de conducta normalizada (0 = igual o mejor que sus pares)",
         y = "Provisión en riesgo (MM$)", fill = "Categoría") +
    theme_bw()

print(grafico2)
ggsave(file.path(carpeta_salida, "grafico2_dispersion.png"), grafico2, width = 9, height = 6, dpi = 150)

#%% CELDA 11 - EXPORTACIÓN

# write_xlsx() no guarda los nombres de fila, así que el código de deudor
# se agrega como primera columna para que no se pierda en el Excel.
# Cada elemento de la lista se escribe como una hoja; el nombre del
# elemento es el nombre de la hoja.
hojas <- list(
    "Fila de espera" = cbind(Deudor = rownames(fila_espera), fila_espera),
    "Control EEFF"   = cbind(Deudor = rownames(control_eeff), control_eeff)
)
write_xlsx(hojas, file.path(carpeta_salida, "resultado_focalizacion.xlsx"))

cat("\nArchivos generados:\n")
cat("  resultado_focalizacion.xlsx\n")
cat("  grafico1_trayectoria.png\n")
cat("  grafico2_dispersion.png\n")