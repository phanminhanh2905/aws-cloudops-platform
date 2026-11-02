CREATE DATABASE IF NOT EXISTS techworld CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE techworld;
CREATE TABLE IF NOT EXISTS categories (
 id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE,
 slug VARCHAR(120) NOT NULL UNIQUE, description VARCHAR(500),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS technologies (
 id INT AUTO_INCREMENT PRIMARY KEY, category_id INT NOT NULL,
 name VARCHAR(150) NOT NULL, slug VARCHAR(180) NOT NULL UNIQUE,
 summary VARCHAR(500) NOT NULL, content LONGTEXT NOT NULL,
 is_published BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (category_id) REFERENCES categories(id),
 INDEX idx_category(category_id), INDEX idx_published(is_published)
);
INSERT IGNORE INTO categories(name,slug,description) VALUES
('Cloud Computing','cloud-computing','Cloud platforms and services.'),
('DevOps','devops','Automation and infrastructure operations.'),
('Containerization','containerization','Containers and orchestration.'),
('Artificial Intelligence','artificial-intelligence','AI and generative AI.'),
('Database','database','Relational and non-relational databases.');
INSERT IGNORE INTO technologies(category_id,name,slug,summary,content)
SELECT id,'Amazon Web Services (AWS)','aws','A cloud platform offering compute, storage, networking and managed services.',
'AWS provides on-demand infrastructure and managed services. Common services include EC2, VPC, Elastic Load Balancing, RDS and CloudWatch.'
FROM categories WHERE slug='cloud-computing';
INSERT IGNORE INTO technologies(category_id,name,slug,summary,content)
SELECT id,'Terraform','terraform','An infrastructure-as-code tool for provisioning cloud resources.',
'Terraform lets teams define infrastructure declaratively, review changes with plans and apply controlled updates.'
FROM categories WHERE slug='devops';
INSERT IGNORE INTO technologies(category_id,name,slug,summary,content)
SELECT id,'Docker','docker','A platform for packaging applications into portable containers.',
'Docker images provide repeatable application environments and help teams build, ship and run software consistently.'
FROM categories WHERE slug='containerization';
INSERT IGNORE INTO technologies(category_id,name,slug,summary,content)
SELECT id,'Kubernetes','kubernetes','A platform for deploying, scaling and operating containerized workloads.',
'Kubernetes manages workloads using resources such as Deployments, Services, ConfigMaps and StatefulSets.'
FROM categories WHERE slug='containerization';
INSERT IGNORE INTO technologies(category_id,name,slug,summary,content)
SELECT id,'Generative AI','generative-ai','AI models that generate text, images, code and other content.',
'Generative AI models learn patterns from data and generate new outputs for assistants, summarization and software development.'
FROM categories WHERE slug='artificial-intelligence';
INSERT IGNORE INTO technologies(category_id,name,slug,summary,content)
SELECT id,'MySQL','mysql','A relational database management system using SQL.',
'MySQL stores structured data in relational tables and supports indexes, transactions, constraints and SQL queries.'
FROM categories WHERE slug='database';
