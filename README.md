# CLARA - Control de Gastos Personales

Una aplicación móvil simple y clara para el control de gastos personales, diseñada para personas que quieren entender en qué se les va el dinero sin complicaciones.

## 🎯 Características Principales

- **Offline-first**: Funciona completamente sin internet
- **Registro rápido**: Agregar un gasto toma menos de 5 segundos
- **Categorización inteligente**: Sugerencias automáticas basadas en el monto
- **Resumen claro**: Totales diarios y mensuales con interpretación simple
- **Alertas inteligentes**: Avisos cuando gastas más de lo normal
- **Diseño minimalista**: Interfaz limpia y fácil de usar

## 📱 Pantallas

1. **Home**: Resumen diario con total gastado y categoría principal
2. **Agregar Gasto**: Modal rápido con auto-sugerencia de categoría
3. **Resumen Mensual**: Desglose por categorías con porcentajes
4. **Ajustes**: Configuración y funciones PRO

## 🏗️ Arquitectura

La app está construida con **Flutter** siguiendo **Clean Architecture**:

```
lib/
├── core/                 # Configuración y utilidades
│   ├── theme/           # Tema y colores
│   └── di/              # Inyección de dependencias
├── domain/              # Lógica de negocio
│   ├── entities/        # Modelos de datos
│   ├── repositories/    # Contratos de repositorios
│   └── usecases/        # Casos de uso
├── data/                # Capa de datos
│   ├── datasources/     # Fuentes de datos locales
│   └── repositories/    # Implementación de repositorios
└── presentation/        # UI y estado
    ├── bloc/            # Manejo de estado
    ├── pages/           # Pantallas
    └── widgets/         # Componentes reutilizables
```

## 🚀 Instalación y Ejecución

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd clara
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 📊 Lógica de Negocio

### Categorías Base
- 🍽️ **Comida**: Gastos de alimentación
- 🚗 **Transporte**: Movilidad y transporte
- 💳 **Deudas**: Pagos de deudas y créditos
- 🛍️ **Compras**: Compras generales
- 📦 **Otros**: Gastos varios

### Sugerencia Automática
- Si monto < $30.000 → Sugerir **Transporte**
- Si monto ≥ $30.000 → Sugerir **Comida**

### Alertas Inteligentes
- Compara gastos semanales con el promedio histórico
- Alerta cuando una categoría supera 20% del promedio
- Mensajes en lenguaje humano y no técnico

## 🎨 Diseño

### Colores
- **Primario**: Verde suave (#4CAF50)
- **Fondo**: Blanco/Gris claro (#FAFAFA)
- **Texto**: Gris oscuro (#212121)

### Principios
- Minimalismo y claridad
- Bordes redondeados
- Mucho espacio en blanco
- Animaciones suaves
- Tipografía Inter

## 🔒 Privacidad

- **100% Offline**: Todos los datos se guardan localmente
- **Sin backend**: No hay servidores externos
- **Sin login**: No requiere cuentas ni registros
- **Control total**: El usuario tiene control completo de sus datos

## 💰 Monetización (Preparada)

### Versión Gratuita
- Funcionalidad completa básica
- Historial limitado
- Exportación básica

### Versión PRO
- Historial ilimitado
- Exportación avanzada en PDF
- Funciones premium adicionales

## 🛠️ Tecnologías

- **Flutter**: Framework de desarrollo
- **Dart**: Lenguaje de programación
- **SharedPreferences**: Almacenamiento local
- **Clean Architecture**: Patrón arquitectónico
- **BLoC Pattern**: Manejo de estado

## 📝 Próximas Funciones

- [ ] Presupuestos mensuales
- [ ] Exportación de reportes PDF
- [ ] Gráficos avanzados
- [ ] Recordatorios de gastos
- [ ] Múltiples monedas
- [ ] Backup y sincronización

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Equipo

Desarrollado como un proyecto de demostración de desarrollo móvil completo con Flutter y Clean Architecture.

---

**CLARA** - Control de gastos simple, claro y humano 💚