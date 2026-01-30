---
trigger: always_on
---

Regras e Convenções do Projeto Maestro
1. Arquitetura e Estrutura de Pastas
Como o projeto visa escalabilidade, adotaremos uma estrutura baseada em funcionalidades (features) e camadas claras.

Estrutura de Diretórios
src/
├── assets/          # Recursos estáticos (imagens, fontes)
├── components/
│   ├── ui/          # Componentes base (Shadcn UI) - Botões, Inputs, Cards
│   └── shared/      # Componentes reutilizáveis globais que não são Shadcn puro
├── composables/     # Lógica reutilizável (Composition API)
├── features/        # Módulos principais do sistema (Domínio)
│   ├── chat/        # Ex: ChatComponent.vue, useChat.js
│   ├── map/         # Ex: MapView.vue, MapControls.vue
│   ├── sheet/       # Fichas de D&D 5e
│   └── campaign/    # Gestão de campanha
├── layouts/         # Layouts de página (MasterLayout, PlayerLayout, AuthLayout)
├── lib/             # Utilitários e configurações de bibliotecas (axios, utils, shadcn)
├── router/          # Configuração de rotas
├── stores/          # Gerenciamento de estado global (Pinia)
└── views/           # Páginas principais (montam as features)
2. Tecnologias e Estilo
Framework: Vue 3 (Composition API + <script setup>)
Estilização: Tailwind CSS v3
Componentes UI: Shadcn-vue (Radix Vue)
Gerenciamento de Estado: Pinia
Ícones: Lucide Vue (padrão do Shadcn)
Tema Dark Fantasy
Cores:
Backgrounds: #171717
Surface: #141414
Accents: #DFD4BD
Borders: #363636
Tipografia:
Headings: Inknut Antiqua (Serifada, robusta)
Body: Inter ou Outfit (Legibilidade)
3. Padrões de Código
Componentes: PascalCase (ex: CharacterCard.vue)
Composables: camelCase iniciando com use (ex: useDiceRoll.js)
Props: Definidas explicitamente com tipos.
Eventos: emit tipados ou definidos no setup.
4. Fluxo de Desenvolvimento
Componentes UI: Ao criar um novo componente visual básico, verifique se existe no Shadcn. Se não, crie em components/ui.
Features: Novas funcionalidades complexas (ex: sistema de inventário) devem residir em features/.
Refatoração: Evite componentes gigantes ("God Components"). Quebre interfaces complexas em sub-componentes menores dentro da pasta da feature.
5. Regras de Interface (UI/UX)
Feedback: Toda ação do usuário deve ter feedback (loading state, toast notification, animação).
Imersão: Manter a estética "Dark Fantasy". Evitar sombras padrão do bootstrap/material. Usar bordas sutis e brilhos (glows).
Responsividade: O sistema do Jogador deve funcionar bem em mobile. O do Mestre foca em Desktop.