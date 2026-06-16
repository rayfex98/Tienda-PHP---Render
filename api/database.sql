-- SQL Script to import into phpMyAdmin for ElectroMart
-- Creates database, tables, and inserts initial data

CREATE DATABASE IF NOT EXISTS electromart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE electromart;

-- 1. Table for Categories
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table for Products
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50) NOT NULL,
    image VARCHAR(255),
    stock INT NOT NULL DEFAULT 0,
    rating DECIMAL(3,1) DEFAULT 5.0,
    specs TEXT, -- stored as JSON string (array of strings)
    featured TINYINT(1) DEFAULT 0,
    FOREIGN KEY (category) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Table for Reviews
CREATE TABLE IF NOT EXISTS reviews (
    id VARCHAR(50) PRIMARY KEY,
    productId VARCHAR(50) NOT NULL,
    userName VARCHAR(255) NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    date DATE NOT NULL,
    FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Table for Contact Messages
CREATE TABLE IF NOT EXISTS messages (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    date DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- DATA SEEDING
-- --------------------------------------------------------

-- Seeding categories
INSERT INTO categories (id, name, icon) VALUES
('todos', 'Todos los Productos', 'Laptop'),
('laptops', 'Laptops y Computadoras', 'Monitor'),
('smartphones', 'Smartphones', 'Smartphone'),
('audio', 'Audio y Música', 'Headphones'),
('wearables', 'Wearables y Relojes', 'Watch'),
('televisiones', 'Televisores y Entretenimiento', 'Tv'),
('hogar-inteligente', 'Hogar Inteligente', 'Home')
ON DUPLICATE KEY UPDATE name=VALUES(name), icon=VALUES(icon);

-- Seeding products
INSERT INTO products (id, name, description, price, category, image, stock, rating, specs, featured) VALUES
('prod-1', 'ZenBook Pro Duo 15"', 'Laptop premium con doble pantalla táctil 4K OLED, procesador Intel Core i9 de última generación, 32GB de RAM y tarjeta gráfica NVIDIA RTX 4070. Ideal para creadores de contenido, diseñadores y programadores altamente exigentes.', 1899.99, 'laptops', 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80', 12, 4.8, '["Pantalla principal: 15.6\\" 4K OLED HDR táctil","Pantalla secundaria: ScreenPad Plus de 14\\"","Procesador: Intel Core i9 de 14 núcleos","Memoria RAM: 32GB LPDDR5","Almacenamiento: 2TB SSD NVMe PCIe 4.0","Gráficos: NVIDIA GeForce RTX 4070 8GB GDDR6","Teclado retroiluminado con numpad digital"]', 1),

('prod-2', 'AeroPhone 15 Pro Max', 'El smartphone definitivo con cuerpo de titanio de grado aeroespacial, sistema de cámaras triples de 48MP con zoom óptico 5x, pantalla Super Retina XDR Pro de 120Hz y el procesador móvil con trazado de rayos más rápido del mundo.', 1199.99, 'smartphones', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80', 25, 4.9, '["Diseño de chasis en Titanio Pulido","Pantalla: Super Retina XDR de 6.7\\" OLED","Frecuencia de actualización dinámica: 1Hz - 120Hz","Procesador: Chip A17 Pro de 3nm","Cámara trasera: Principal 48MP f/1.78, Telefoto 5x 12MP, Gran Angular 12MP","Batería: Hasta 29 horas de reproducción de video","Carga segura con imán MagSafe de 15W"]', 1),

('prod-3', 'Sony WH-1000XM5 ANC', 'Auriculares inalámbricos de diadema con cancelación de ruido de referencia líder en la industria. Ofrecen una calidad de audio de alta resolución con transductores de precisión y confort insuperable para largas horas de viaje o trabajo.', 349.99, 'audio', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80', 18, 4.7, '["Cancelación Activa de Ruido (ANC) de 8 micrófonos","Procesador integrado V1 para cancelación óptima","Autonomía de batería: Hasta 30 horas con ANC activo","Carga ultrarrápida: 3 horas de uso con solo 3 min de carga","Control táctil inteligente en la copa lateral","Conexión multipunto Bluetooth 5.2 simultánea","Sensor de proximidad de pausa de audio automática"]', 1),

('prod-4', 'Vanguard Watch Ultra 2', 'Reloj inteligente definitivo para deportes de aventura y supervivencia. Con caja de titanio premium de 49mm, resistencia al agua hasta 100 metros, GPS de doble frecuencia y una batería que rinde múltiples días seguidos sin recarga.', 799.99, 'wearables', 'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6?w=600&auto=format&fit=crop&q=80', 8, 4.6, '["Caja de titanio de 49 mm y cristal de zafiro","Brillo de pantalla extremo de hasta 3000 nits","Resistencia al agua: Certificación IP6X y buceo recreativo 40m","Autonomía: Hasta 36 horas de uso estándar u 72h bajo consumo","Medición de Oxígeno en Sangre, Ritmo Cardíaco y ECG","Sirena de emergencia integrada de 86 decibelios","GPS de precisión de doble frecuencia L1 y L5"]', 1),

('prod-5', 'Neo QLED TV 65" Cinema', 'Disfruta de una calidad de imagen inmejorable con tecnología de retroiluminación Mini LED que aporta negros perfectos y un contraste insólito. Modo de juego avanzado de 144Hz para jugadores profesionales y altavoces Dolby Atmos integrados.', 1499.00, 'televisiones', 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=600&auto=format&fit=crop&q=80', 5, 4.5, '["Pantalla de 65 pulgadas con resolución 4K Real","Tecnología Quantum Matrix con Mini LEDs de precisión","Procesador Neural Quantum 4K con IA","Tasa de refresco: Freesync Premium Pro a 144Hz","Sonido: Dolby Atmos con altavoces de 60W y 2.2.2 canales","Diseño delgado NeoSlim premium sin marcos","Smart TV con acceso directo a streaming y Xbox Cloud Hub"]', 0),

('prod-6', 'Smart Soundbar Atmos Elite', 'Barra de sonido inteligente con soporte integrado para Dolby Atmos y control por voz. Sumérgete en tu cine en casa con canales acústicos multidireccionales que rebotan el sonido por todo el salón recreando un teatro auditivo.', 699.99, 'audio', 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600&auto=format&fit=crop&q=80', 14, 4.4, '["9 altavoces internos dispuestos con ingeniería de precisión","Dos altavoces dipolo que proyectan audio hacia arriba","Conexión: Entrada HDMI eARC, óptica y compatibilidad AirPlay 2","Bluetooth y Wi-Fi integrados con Spotify Connect","Tecnología de calibración propietaria ADAPTiQ","Compatible con asistentes de voz Amazon Alexa y Google Assistant"]', 0),

('prod-7', 'AeroPad Air M2 Studio', 'La tablet versátil perfecta con pantalla de retina de 11 pulgadas, chip M2 ultrarápido para renderizado y edición sobre la marcha. Soportado con reconocimiento biométrico avanzado, altavoces estéreo magníficos y una pluma magnética receptiva.', 599.99, 'laptops', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&auto=format&fit=crop&q=80', 22, 4.7, '["Chip M2 potente con CPU de 8 núcleos y GPU de 10 núcleos","Pantalla: Liquid Retina de 11\\" True Tone y color P3","Almacenamiento base: 128GB de estado sólido","Cámara trasera de 12MP y frontal ultra gran angular 12MP","Wi-Fi 6E y puerto de transferencia USB-C Thunderbolt","Soporte completo para teclado flotante acoplable"]', 0),

('prod-8', 'Domus Nest Hub Starter Kit', 'Domina cada gadget de tu casa inteligente con esta pantalla inteligente interactiva acompañada de dos bombillos RGB multiespectro. Administra la calefacción, visualiza cámaras perimetrales o reproduce podcasts con comandos de voz cómodos.', 129.99, 'hogar-inteligente', 'https://images.unsplash.com/photo-1558002038-1055907df827?w=600&auto=format&fit=crop&q=80', 40, 4.3, '["Pantalla inteligente HD antirreflejos de 7 pulgadas","Altavoz de rango completo y matriz de micrófonos lejanos","Tecnología Motion Sense para suspender alarmas sin contacto","Incluye 2 bombillas inteligentes RGB E27 de 10W (900 lúmenes)","Protocolos compatibles: Matter, Thread, Zigbee y Wi-Fi","Privacidad física: Interruptor de apagado físico para el micrófono"]', 0)
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), price=VALUES(price), category=VALUES(category), image=VALUES(image), stock=VALUES(stock), rating=VALUES(rating), specs=VALUES(specs), featured=VALUES(featured);

-- Seeding reviews
INSERT INTO reviews (id, productId, userName, rating, comment, date) VALUES
('rev-1', 'prod-1', 'Carlos Mendoza', 5, 'La pantalla secundaria es increíble para programar y tener la documentación abierta. La potencia gráfica es impresionante.', '2026-05-15'),
('rev-2', 'prod-1', 'Sofía Gutiérrez', 4, 'Excelente laptop para renderizar video. El único detalle es la duración de la batería por la potencia y las dos pantallas, por lo demás excelente.', '2026-06-02'),
('rev-3', 'prod-2', 'Valentina Rojas', 5, 'El acabado en titanio se siente súper lujoso. La cámara toma fotos de noche con un nivel de detalle que nunca había visto.', '2026-06-10'),
('rev-4', 'prod-3', 'Andrés López', 5, 'Llevo utilizándolos una semana en el tren de camino al trabajo y aíslan el ruido por completo. Muy recomendados.', '2026-04-20')
ON DUPLICATE KEY UPDATE productId=VALUES(productId), userName=VALUES(userName), rating=VALUES(rating), comment=VALUES(comment), date=VALUES(date);
