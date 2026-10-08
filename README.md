# Finanzas en R — Proyecto final

**Modelo de focalización de revisión para cartera comercial mayorista A4–A6.**
Construye una fila de espera semanal que indica a qué deudores revisar primero:

> **Prioridad = brecha de conducta (0 a 1) × provisión en riesgo (MM$)**

El modelo **no reclasifica, ordena**. La decisión de reclasificar sigue siendo
del analista. Todos los datos son sintéticos.

Autor: Felipe Zúñiga · Diploma en Ciencia de Datos para las Finanzas, FEN
Universidad de Chile · Profesor: Sebastián Egaña

## Entregas

| Carpeta | Contenido | Archivo principal |
|---|---|---|
| [`Entrega 01/`](Entrega%2001/) | Descripción de la solución y planificación (carta Gantt) | `entrega01.qmd` → `entrega01.pdf` |
| [`Entrega 02/`](Entrega%2002/) | MVP: código del modelo y salidas (Excel y gráficos) | `Entrega02.R` (ver su [README](Entrega%2002/README.md)) |
| [`Entrega 03/`](Entrega%2003/) | Model card, limpieza y transformación de datos, diagrama del flujo, versionado, despliegue y monitoreo | `entrega03.qmd` → `entrega03.pdf` |

## Reproducir

Requiere R 4.6.1. Las dependencias se gestionan con
[renv](https://rstudio.github.io/renv/).

```
git clone https://github.com/fzunigae/Finanzas-en-R-proyecto.git
```

Con la **raíz del repositorio** como directorio de trabajo (así el
`.Rprofile` activa renv):

```r
renv::restore()
source("Entrega 02/Entrega02.R", encoding = "UTF-8")
```

Los documentos de las entregas 01 y 03 se generan con Quarto (formato Typst):

```
quarto render "Entrega 03/entrega03.qmd"
```

## Versiones del modelo

| Tag | Descripción |
|---|---|
| `v1-port` | Port a R del MVP original. Categoría como número en la regresión |
| `v2` | Categoría como factor. Test F contra v1: p = 0,014 |
| `v3` | Entrega 03: documentación, despliegue y monitoreo. Sin cambios en el modelo |
