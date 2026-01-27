SELECT *
FROM layoffs;

-- Criar tabela temporária, para que possamos ajusta-la e se houver algum erro ainda sim teremos a original.

CREATE TABLE layoffs_temporario
LIKE layoffs;

INSERT layoffs_temporario
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_temporario;

-- 1. REMOVER DUPLICATAS

-- Identifica linhas duplicadas, numerando cada repetição.

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location,  industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_temporario
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Criar um nova tabela adicionando a coluna row_num, para assim conseguir excluir as linhas duplicadas

CREATE TABLE `layoffs_temporario2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_temporario2;

INSERT INTO layoffs_temporario2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location,  industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_temporario;

DELETE 
FROM layoffs_temporario2
WHERE row_num > 1;

-- 2. PADRONIZAR OS DADOS

-- Ajustar espaços desnecessários

SELECT company
FROM layoffs_temporario2;

UPDATE layoffs_temporario2
SET company = TRIM(company);

-- Ajustar indústrias que aparecem como diferentes mas são as mesmas

SELECT DISTINCT(industry)
FROM layoffs_temporario2
ORDER BY 1;

SELECT *
FROM layoffs_temporario2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_temporario2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Ajustar países que aparecem como diferentes mas são os mesmos

SELECT DISTINCT(country)
FROM layoffs_temporario2
ORDER BY 1;

SELECT DISTINCT(country)
FROM layoffs_temporario2
WHERE country LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_temporario2
SET country = TRIM(TRAILING'.' FROM country)
WHERE country LIKE 'United States%';

-- Alterar o tipo da coluna da data de TEXT para DATE

SELECT `date`
FROM layoffs_temporario2;

-- Valores em si

UPDATE layoffs_temporario2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Coluna 

ALTER TABLE layoffs_temporario2
MODIFY COLUMN `date` DATE;

-- 3. VALORES NULOS OU EM BRANCO

SELECT *
FROM layoffs_temporario2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Linha onde a industrias estão sem dados porém que são da mesma empresa que outra linha com dado
SELECT *
FROM layoffs_temporario2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_temporario2
WHERE company = 'Airbnb';

UPDATE layoffs_temporario2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_temporario2 t1
JOIN layoffs_temporario2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_temporario2 t1
JOIN layoffs_temporario2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. REMOVER QUAISQUER COLUNAS

ALTER TABLE layoffs_temporario2
DROP COLUMN row_num