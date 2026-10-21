# Superfighters Remake (1:1 ActionScript 3 Port)

> Remake autêntico e cirúrgico do clássico jogo de ação e tiro em Flash **Superfighters (2011)**, desenvolvido em **TypeScript**, **PixiJS v8** e **Planck.js (Box2D)** com simulação física fixa a 30 Hz.

---

## 📖 Documentação Importante

- 🔍 **[CONTEXTO_E_DIFICULDADES.md](./CONTEXTO_E_DIFICULDADES.md)**: Documento aprofundado para análise arquitetural, descrevendo o funcionamento do motor original do Flash, os desafios de física, colisão de rampas, matrizes de animação e perguntas abertas para revisão por IA e engenheiros.
- 📋 **[superfighters-remake-plan.md](./superfighters-remake-plan.md)**: Plano Mestre de Paridade (único plano ativo), com diagnóstico técnico das divergências, regras estritas de port, estratégia do oráculo golden e roteiro fase a fase.
- 🛠️ **[tools/README.md](./tools/README.md)**: Guia dos scripts de extração do SWF e simuladores de física em Python.

---

## 🕹️ Como Rodar o Jogo Localmente

### Pré-requisitos
- **Node.js** (v18+) e **npm**
- **Python 3** (opcional, para executar os scripts de simulação de física em `tools/`)

### Execução

```bash
# 1. Navegar até o diretório da aplicação web
cd superfighters-web

# 2. Instalar as dependências do projeto
npm install

# 3. Rodar os testes automatizados
npm run test

# 4. Iniciar o servidor de desenvolvimento
npm run dev
```

Abra seu navegador em: **`http://localhost:5173/`**

### Controles no Navegador
- **A / D**: Mover para a esquerda / direita
- **W / Espaço**: Pular (sustentar pressionado aumenta o impulso por até 4 ticks)
- **S**: Agachar / Rolar
- **Shift + A/D**: Correr (Sprint)
- **Shift + W**: Mergulho corporal (*Dive*)
- **H**: Alternar visualização das hitboxes de depuração (Vermelho = Billy, Magenta = Solo, Ciano = Semi-sólido, Amarelo = Escadas)
- **C**: Alternar câmera livre vs perseguição do jogador
- **Scroll do mouse**: Zoom manual da câmera
- **Arrastar mouse**: Pan manual da câmera

---

## 🏛️ Estrutura do Repositório

```
remake-superfighters/
├── .agents/                    # Memória de contexto, regras e histórico de decisões
├── decompiled/                 # Código original descompilado do Flash
│   ├── assets/                 # Bitmaps PNG, 74 efeitos sonoros WAV e sprites SWF
│   └── scripts/scripts/Code/   # 442 arquivos de classes ActionScript 3 (Ground Truth)
├── superfighters-web/          # Aplicação web (TypeScript + PixiJS + Planck.js)
│   ├── src/                    # Código-fonte do jogo
│   └── tests/                  # Suíte de testes unitários em Vitest
├── tools/                      # Utilitários de extração e testes em Python
├── CONTEXTO_E_DIFICULDADES.md  # Relatório aprofundado de desafios e arquitetura
└── superfighters-remake-plan.md # Plano de execução fase a fase
```

---

## ⚖️ Licença e Créditos
Superfighters é uma criação original da **MythoLogic Interactive** (Johan Hjärpe & Alexander Lemetti). Este projeto é um trabalho sem fins lucrativos dedicado à preservação digital e reconstrução técnica do clássico Flash.
