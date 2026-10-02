# Entrega 02 — MVP: fila de espera priorizada de revisión (cartera A4–A6)

Producto mínimo viable del proyecto final de *Finanzas en R*. A partir del
comportamiento de pago de una cartera comercial mayorista A4–A6, el script
construye una **fila de espera** que indica a qué deudores revisar primero:

> **Prioridad = brecha de conducta (0 a 1) × provisión en riesgo (MM$)**

- **Brecha de conducta:** cuánto peor se comporta el deudor que el promedio de
  sus pares de igual categoría (residuo de una regresión).
- **Provisión en riesgo:** provisión adicional que exigiría una migración de un
  escalón, según la tabla de pérdida esperada del Capítulo B-1 (CMF).

El modelo **no reclasifica, ordena**. La decisión de reclasificar sigue siendo
del analista.

El detalle del problema, la lógica, los resultados y las limitaciones está en
el encabezado de [`Entrega02.R`](Entrega02.R).

## Requisitos

- R 4.6.1
- Paquetes gestionados con [renv](https://rstudio.github.io/renv/): `ggplot2`
  y `writexl`, con las versiones fijadas en `renv.lock` (en la raíz del
  repositorio).

## Cómo ejecutarlo

1. Clonar el repositorio:

   ```
   git clone https://github.com/fzunigae/Finanzas-en-R-proyecto.git
   ```

2. Abrir R (o RStudio) con la **raíz del repositorio** como directorio de
   trabajo, no la carpeta `Entrega 02/`. Al iniciar, el `.Rprofile` de la
   raíz activa renv automáticamente.

3. Instalar las versiones exactas de los paquetes:

   ```r
   renv::restore()
   ```

4. Ejecutar el script:

   ```r
   source("Entrega 02/Entrega02.R", encoding = "UTF-8")
   ```

> **Importante:** el script escribe sus salidas en `Entrega 02/` con rutas
> relativas a la raíz. Si se ejecuta con otro directorio de trabajo, renv no
> se activa y las salidas no se encuentran.

La ejecución completa toma unos segundos. La semilla está fija
(`set.seed(42)`), así que cada ejecución reproduce exactamente las mismas cifras.

## Salidas

| Archivo | Contenido |
|---|---|
| `resultado_focalizacion.xlsx` | Hoja **Fila de espera**: los 137 deudores ordenados por índice de prioridad, con una columna de justificación. Hoja **Control EEFF**: deudores A4/A5 con estados financieros vencidos (regla normativa, separada del puntaje). |
| `grafico1_trayectoria.png` | Trayectoria semanal de mora del deudor prioritario, con el umbral de 90 días. |
| `grafico2_dispersion.png` | Brecha de conducta vs. provisión en riesgo, por categoría. |

Además, la consola muestra la estadística descriptiva, las correlaciones, la
regresión y la comparación contra la versión anterior del modelo.

## Versiones del modelo

| Tag | Descripción |
|---|---|
| `v1-port` | Port fiel a R del MVP original en Python. La categoría entra en la regresión como número (4, 5, 6). |
| `v2` | La categoría entra como factor. Así el valor esperado de cada deudor es el promedio de sus pares, sin suponer saltos iguales entre categorías. El test F rechaza el supuesto de la v1 (p = 0,014), y 9 de los 10 primeros de la fila de espera se mantienen. |

Para comparar ambas versiones:

```
git diff v1-port v2 -- "Entrega 02/Entrega02.R"
```

## Datos

**Todos los datos son sintéticos.** Se generan por simulación con semilla
fija y fueron calibrados contra las probabilidades de incumplimiento del
Capítulo B-1. No se usa información real de clientes.
