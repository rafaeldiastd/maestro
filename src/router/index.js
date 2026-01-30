import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../lib/supabaseClient'
import LoginView from '../features/auth/views/LoginView.vue'
import DashboardView from '../features/dashboard/views/DashboardView.vue'
import MasterView from '../features/campaign/views/MasterCampaignView.vue'
import PlayerView from '../features/campaign/views/PlayerCampaignView.vue'
import SettingsView from '../features/campaign/views/SettingsView.vue'
import AcceptInvitePage from '../features/campaign/views/AcceptInvitePage.vue'

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'login',
            component: LoginView
        },
        {
            path: '/dashboard',
            name: 'dashboard',
            component: DashboardView,
            meta: { requiresAuth: true }
        },
        {
            path: '/play/:id',
            name: 'master',
            component: MasterView,
            meta: { requiresAuth: true }
        },
        {
            path: '/join/:id',
            name: 'player',
            component: PlayerView
        },
        {
            path: '/campaign/:id/settings',
            name: 'campaign-settings',
            component: SettingsView,
            meta: { requiresAuth: true }
        },
        {
            path: '/invite/accept/:token',
            name: 'accept-invite',
            component: AcceptInvitePage
        },
        {
            path: '/stream/:id',
            name: 'stream',
            component: () => import('../features/stream/views/StreamView.vue')
        },
        {
            path: '/campaign/:id/maps',
            name: 'maps-list',
            component: () => import('../features/maps/views/MapsListView.vue'),
            meta: { requiresAuth: true }
        },
        {
            path: '/campaign/:id/map/:mapId',
            name: 'map-editor',
            component: () => import('../features/maps/views/MapEditorView.vue'),
            meta: { requiresAuth: true }
        },
        // Legacy Redirect
        {
            path: '/session',
            redirect: '/'
        }
    ]
})

// Navigation Guard
router.beforeEach(async (to, from, next) => {
    const { data: { session } } = await supabase.auth.getSession()

    if (to.meta.requiresAuth && !session) {
        next('/')
    } else if (to.path === '/' && session) {
        // If logged in and trying to go to login, send to dashboard
        next('/dashboard')
    } else {
        next()
    }
})

export default router
