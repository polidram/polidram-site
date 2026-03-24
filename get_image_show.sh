#!/bin/bash

# ============================================
# Script: generate_images_list.sh
# Descrição: Gera lista de imagens da pasta showroom
# Uso: ./generate_images_list.sh
# ============================================

# Configurações
SHOWROOM_DIR="img/showroom"
OUTPUT_FILE="img/images_list.json"

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Gerando lista de imagens do showroom${NC}"
echo -e "${YELLOW}========================================${NC}"

# Verificar se a pasta showroom existe
if [ ! -d "$SHOWROOM_DIR" ]; then
    echo -e "${RED}ERRO: Pasta '$SHOWROOM_DIR' não encontrada!${NC}"
    echo -e "${YELLOW}Criando pasta...${NC}"
    mkdir -p "$SHOWROOM_DIR"
    echo -e "${GREEN}Pasta criada: $SHOWROOM_DIR${NC}"
    echo -e "${RED}Adicione imagens à pasta e execute o script novamente.${NC}"
    exit 1
fi

# Contar imagens
IMAGE_COUNT=$(find "$SHOWROOM_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \) | wc -l)

if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo -e "${RED}Nenhuma imagem encontrada na pasta '$SHOWROOM_DIR'${NC}"
    echo -e "${YELLOW}Formatos suportados: jpg, jpeg, png, webp, gif, bmp${NC}"
    
    # Criar arquivo JSON vazio
    echo '{"images": [], "total": 0, "last_update": ""}' > "$OUTPUT_FILE"
    echo -e "${RED}Arquivo vazio criado: $OUTPUT_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}Encontradas $IMAGE_COUNT imagens${NC}"

# Gerar JSON com a lista de imagens
echo "[" > "$OUTPUT_FILE.tmp"

# Processar cada imagem
first=true
find "$SHOWROOM_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \) | sort | while read -r file; do
    # Extrair apenas o nome do arquivo (sem o caminho)
    filename=$(basename "$file")
    
    # Adicionar vírgula se não for o primeiro
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE.tmp"
    fi
    
    # Escrever o JSON para este arquivo
    echo -n "  \"$filename\"" >> "$OUTPUT_FILE.tmp"
done

# Fechar o array
echo "" >> "$OUTPUT_FILE.tmp"
echo "]" >> "$OUTPUT_FILE.tmp"

# Criar JSON completo com metadados
TIMESTAMP=$(date -Iseconds)
cat > "$OUTPUT_FILE" << EOF
{
  "images": $(cat "$OUTPUT_FILE.tmp"),
  "total": $IMAGE_COUNT,
  "last_update": "$TIMESTAMP"
}
EOF

# Limpar arquivo temporário
rm -f "$OUTPUT_FILE.tmp"

# Formatar JSON com python (se disponível) para melhor legibilidade
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" 2>/dev/null && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
    echo -e "${GREEN}JSON formatado com sucesso!${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Arquivo gerado: $OUTPUT_FILE${NC}"
echo -e "${GREEN}Total de imagens: $IMAGE_COUNT${NC}"
echo -e "${GREEN}Última atualização: $TIMESTAMP${NC}"
echo -e "${GREEN}========================================${NC}"

# Mostrar as primeiras 5 imagens como exemplo
echo -e "${YELLOW}Primeiras imagens encontradas:${NC}"
find "$SHOWROOM_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -5 | while read -r file; do
    echo -e "${GREEN}  - $(basename "$file")${NC}"
done

if [ "$IMAGE_COUNT" -gt 5 ]; then
    echo -e "${YELLOW}  ... e mais $((IMAGE_COUNT - 5)) imagem(ns)${NC}"
fi

echo ""
echo -e "${YELLOW}Dica: Adicione este comando ao seu fluxo de trabalho:${NC}"
echo -e "${GREEN}  ./generate_images_list.sh${NC}"