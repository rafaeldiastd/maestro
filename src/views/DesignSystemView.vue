<script setup>
import { Button } from '@/components/ui/button'
import { Toggle } from '@/components/ui/toggle'
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Switch } from '@/components/ui/switch'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import { Select, SelectContent, SelectGroup, SelectItem, SelectLabel, SelectTrigger, SelectValue } from '@/components/ui/select'
import ChatMessage from '@/features/chat/components/ChatMessage.vue'
import { ref } from 'vue'
import { Search, Plus, Trash, Settings, Save, X, Mail, Bell, Home, User, Map as MapIcon, MessageSquare, Send, Bold, Italic, Underline } from 'lucide-vue-next'

// Mock Data
const inputValue = ref('')
const switchValue = ref(false)
const checkboxValue = ref(true)
const radioValue = ref('option-one')
const currentTab = ref('account')
const selectValue = ref('')

const messages = [
    {
        id: 1,
        user_id: 'gm-id',
        content: "Welcome to the campaign! This is a system message.",
        created_at: new Date().toISOString(),
        recipient_id: null
    },
    {
        id: 2,
        user_id: 'my-id',
        content: "Ready to roll some dice? Let's go!",
        created_at: new Date().toISOString(),
        recipient_id: null
    },
    {
        id: 3,
        user_id: 'gm-id',
        content: JSON.stringify({ type: 'roll', total: 20, formula: '1d20', rolls: [20] }),
        created_at: new Date().toISOString(),
        recipient_id: null
    }
]
const currentUserId = 'my-id'
</script>

<template>
    <div class="min-h-screen bg-background text-foreground p-8 space-y-12 pb-32">

        <!-- Header -->
        <div class="space-y-2 border-b border-border pb-6">
            <h1 class="text-4xl font-serif font-bold text-lumina-text">Maestro Design System</h1>
            <p class="text-lumina-text-muted">Dark Fantasy Theme (Lumina) • Standard Components</p>
        </div>

        <!-- Colors -->
        <section class="space-y-4">
            <h2 class="text-2xl font-serif font-semibold border-b border-border pb-2 group flex items-center gap-2">
                Colors
                <span
                    class="text-xs font-sans font-normal px-2 py-0.5 rounded-full bg-muted text-muted-foreground">Theme
                    Palette</span>
            </h2>
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                <div class="space-y-1">
                    <div class="h-20 w-full rounded-lg bg-background border border-border shadow-sm"></div>
                    <p class="text-xs font-mono">bg-background</p>
                </div>
                <div class="space-y-1">
                    <div class="h-20 w-full rounded-lg bg-card border border-border"></div>
                    <p class="text-xs font-mono">bg-card</p>
                </div>
                <div class="space-y-1">
                    <div class="h-20 w-full rounded-lg bg-popover border border-border"></div>
                    <p class="text-xs font-mono">bg-popover</p>
                </div>
                <div class="space-y-1">
                    <div class="h-20 w-full rounded-lg bg-primary shadow-lg shadow-primary/20"></div>
                    <p class="text-xs font-mono">bg-primary (Gold)</p>
                </div>
                <div class="space-y-1">
                    <div
                        class="h-20 w-full rounded-lg bg-secondary text-secondary-foreground flex items-center justify-center font-medium">
                        Secondary</div>
                    <p class="text-xs font-mono">bg-secondary</p>
                </div>
                <div class="space-y-1">
                    <div class="h-20 w-full rounded-lg bg-muted text-muted-foreground flex items-center justify-center">
                        Muted</div>
                    <p class="text-xs font-mono">bg-muted</p>
                </div>
                <div class="space-y-1">
                    <div
                        class="h-20 w-full rounded-lg bg-destructive/20 border border-destructive text-destructive flex items-center justify-center">
                        Error</div>
                    <p class="text-xs font-mono">bg-destructive</p>
                </div>
                <div class="space-y-1">
                    <div
                        class="h-20 w-full rounded-lg bg-accent text-accent-foreground flex items-center justify-center">
                        Hover</div>
                    <p class="text-xs font-mono">bg-accent</p>
                </div>
                <!-- Sidebar Standard -->
                <div class="h-64 w-64 border rounded-lg overflow-hidden relative bg-background">
                    <img src="https://picsum.photos/400/400" class="absolute inset-0 object-cover opacity-50" />
                    <!-- Solid Standard -->
                    <div class="absolute inset-y-0 right-0 w-32 bg-card border-l flex flex-col">
                        <div class="h-10 border-b flex items-center px-2 text-xs font-bold">
                            Sidebar
                        </div>
                        <div class="p-2 text-[10px] text-muted-foreground">
                            Solid Standard
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Typography -->
        <section class="space-y-4">
            <h2 class="text-2xl font-serif font-bold text-primary">Typography</h2>
            <div class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <div class="space-y-2">
                        <span class="text-xs text-muted-foreground uppercase tracking-wider">Serif (Inknut
                            Antiqua)</span>
                        <h1 class="text-4xl font-serif font-bold">The quick brown fox jumps</h1>
                        <h2 class="text-3xl font-serif font-semibold">over the lazy dog</h2>
                    </div>
                    <div class="space-y-2">
                        <span class="text-xs text-muted-foreground uppercase tracking-wider">Sans (Inter)</span>
                        <p class="text-base leading-relaxed">
                            Start by creating/modifying index.css, Implement the core design system with all tokens and
                            utilities.
                            Avoid generic colors (plain red, blue, green). Use curated, harmonious color palettes.
                        </p>
                        <p class="text-sm text-lumina-text-muted">Muted text for secondary information.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Buttons -->
        <section class="space-y-4">
            <h2 class="text-2xl font-serif font-semibold border-b border-border pb-2">Buttons</h2>
            <div class="space-y-6">
                <div class="flex flex-wrap gap-4 items-center p-6 border rounded-lg bg-card/50">
                    <Button>Default Action</Button>
                    <Button variant="secondary">Secondary</Button>
                    <Button variant="outline">Outline</Button>
                    <Button variant="ghost">Ghost Button</Button>
                    <Button variant="destructive">Destructive</Button>
                    <Button variant="link">Link Button</Button>
                </div>
                <div class="flex flex-wrap gap-4 items-center">
                    <Button size="sm">
                        <Save class="w-3.5 h-3.5 mr-2" />
                        Save
                    </Button>
                    <Button variant="outline">
                        <Settings class="w-4 h-4 mr-2" />
                        Configure
                    </Button>
                    <Button variant="ghost" size="icon">
                        <Bell class="w-5 h-5" />
                    </Button>
                    <div class="flex items-center gap-2">
                        <Button variant="secondary" size="icon" class="rounded-full">
                            <User class="w-4 h-4" />
                        </Button>
                        <span class="text-xs text-muted-foreground">Pill / Circle</span>
                    </div>
                </div>
            </div>
            <!-- Toggle Buttons -->
            <div class="flex flex-wrap gap-4 items-center mt-4 pt-4 border-t border-border/50">
                <Toggle aria-label="Toggle bold">
                    <Bold class="h-4 w-4" />
                </Toggle>
                <Toggle variant="outline" aria-label="Toggle italic">
                    <Italic class="h-4 w-4" />
                </Toggle>
                <Toggle aria-label="Toggle underline">
                    <Underline class="h-4 w-4" />
                </Toggle>
                <span class="text-xs text-muted-foreground">Toggle State (Pressed)</span>
            </div>
        </section>

        <!-- Navigation Components -->
        <section class="space-y-8">
            <h2 class="text-2xl font-serif font-semibold border-b border-border pb-2">Navigation & Layout</h2>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <!-- Tabs -->
                <div class="space-y-4">
                    <h3 class="text-lg font-medium">Tabs</h3>
                    <Tabs default-value="account" class="w-[400px]">
                        <TabsList>
                            <TabsTrigger value="account">Account</TabsTrigger>
                            <TabsTrigger value="password">Password</TabsTrigger>
                            <TabsTrigger value="settings">Settings</TabsTrigger>
                        </TabsList>
                        <TabsContent value="account">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Account</CardTitle>
                                    <CardDescription>Make changes to your account here.</CardDescription>
                                </CardHeader>
                                <CardContent class="space-y-2">
                                    <div class="space-y-1">
                                        <label class="text-sm">Name</label>
                                        <Input model-value="Rafael Dias" />
                                    </div>
                                </CardContent>
                                <CardFooter>
                                    <Button>Save changes</Button>
                                </CardFooter>
                            </Card>
                        </TabsContent>
                        <TabsContent value="password">
                            <Card>
                                <CardContent class="pt-6">
                                    <p class="text-sm text-muted-foreground">Change your password here.</p>
                                </CardContent>
                            </Card>
                        </TabsContent>
                    </Tabs>
                </div>

                <!-- Navbar / Sidebar Mock -->
                <div class="space-y-4">
                    <h3 class="text-lg font-medium">Sidebar Pattern</h3>
                    <div class="flex h-[300px] w-full border rounded-lg overflow-hidden">
                        <!-- Icon Sidebar -->
                        <div class="w-16 border-r bg-card flex flex-col items-center py-4 gap-4">
                            <Button variant="ghost" size="icon" class="text-primary bg-primary/10 rounded-xl">
                                <Home class="w-5 h-5" />
                            </Button>
                            <Button variant="ghost" size="icon" class="text-muted-foreground hover:text-foreground">
                                <MapIcon class="w-5 h-5" />
                            </Button>
                            <Button variant="ghost" size="icon" class="text-muted-foreground hover:text-foreground">
                                <MessageSquare class="w-5 h-5" />
                            </Button>
                            <div class="mt-auto">
                                <Avatar class="h-10 w-10 border border-border">
                                    <AvatarFallback>RD</AvatarFallback>
                                </Avatar>
                            </div>
                        </div>
                        <!-- Content -->
                        <div class="flex-1 bg-background p-6">
                            <div
                                class="h-full border border-dashed border-border rounded-lg flex items-center justify-center text-muted-foreground">
                                Main Content Area
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Inputs & Forms -->
        <section class="space-y-4">
            <h2 class="text-2xl font-serif font-semibold border-b border-border pb-2">Form Elements</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-12">

                <div class="space-y-6">
                    <!-- Text Inputs -->
                    <div class="space-y-2">
                        <label class="text-sm font-medium">Standard Input</label>
                        <Input v-model="inputValue" placeholder="Enter text..." />
                    </div>

                    <div class="space-y-2">
                        <label class="text-sm font-medium">Textarea</label>
                        <Textarea placeholder="Type your message here." />
                    </div>

                    <div class="space-y-2">
                        <label class="text-sm font-medium">Select</label>
                        <Select>
                            <SelectTrigger>
                                <SelectValue placeholder="Select a system" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectGroup>
                                    <SelectLabel>Systems</SelectLabel>
                                    <SelectItem value="dnd5e">D&D 5e</SelectItem>
                                    <SelectItem value="pf2e">Pathfinder 2e</SelectItem>
                                    <SelectItem value="coc">Call of Cthulhu</SelectItem>
                                </SelectGroup>
                            </SelectContent>
                        </Select>
                    </div>
                </div>

                <div class="space-y-6">
                    <!-- Toggles & Checks -->
                    <div class="flex items-center space-x-2">
                        <Switch id="airplane-mode" :checked="switchValue" @update:checked="switchValue = $event" />
                        <label htmlFor="airplane-mode" class="text-sm font-medium">Enable Notifications</label>
                    </div>

                    <div class="flex items-center space-x-2">
                        <Checkbox id="terms" :checked="checkboxValue" @update:checked="checkboxValue = $event" />
                        <label htmlFor="terms"
                            class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                            Accept terms and conditions
                        </label>
                    </div>

                    <div class="space-y-3">
                        <label class="text-sm font-medium">Radio Group</label>
                        <RadioGroup v-model="radioValue">
                            <div class="flex items-center space-x-2">
                                <RadioGroupItem value="option-one" id="option-one" />
                                <label htmlFor="option-one">Default View</label>
                            </div>
                            <div class="flex items-center space-x-2">
                                <RadioGroupItem value="option-two" id="option-two" />
                                <label htmlFor="option-two">Compact View</label>
                            </div>
                        </RadioGroup>
                    </div>
                </div>
            </div>
        </section>

        <!-- Features & Feedback -->
        <section class="space-y-4">
            <h2 class="text-2xl font-serif font-semibold border-b border-border pb-2">Features & Feedback</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                <!-- Cards -->
                <Card>
                    <CardHeader>
                        <div class="flex items-center justify-between">
                            <CardTitle>Session 42</CardTitle>
                            <span class="text-xs text-muted-foreground border px-2 py-0.5 rounded-full">In
                                Progress</span>
                        </div>
                        <CardDescription>The Dark Tower</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div class="flex -space-x-2 overflow-hidden mb-4">
                            <Avatar class="inline-block h-8 w-8 ring-2 ring-background">
                                <AvatarFallback>A</AvatarFallback>
                            </Avatar>
                            <Avatar class="inline-block h-8 w-8 ring-2 ring-background">
                                <AvatarFallback>B</AvatarFallback>
                            </Avatar>
                            <Avatar class="inline-block h-8 w-8 ring-2 ring-background">
                                <AvatarFallback>C</AvatarFallback>
                            </Avatar>
                        </div>
                        <p class="text-sm text-balance">The party attempts to infiltrate the wizard's spire.</p>
                    </CardContent>
                    <CardFooter>
                        <Button class="w-full">Join Session</Button>
                    </CardFooter>
                </Card>

                <!-- Chat Component -->
                <div class="border rounded-lg bg-background flex flex-col h-[500px]">
                    <div class="p-3 border-b text-sm font-medium flex items-center gap-2">
                        <MessageSquare class="w-4 h-4 text-primary" />
                        Campaign Chat Demo
                    </div>

                    <!-- Messages Area (Standard Scroll) -->
                    <div class="flex-1 p-4 space-y-4 overflow-y-auto scrollbar-thin bg-background/50">
                        <ChatMessage v-for="msg in messages" :key="msg.id" :message="msg"
                            :current-user-id="currentUserId" :is-owner="true"
                            :sender-name="msg.user_id === 'gm-id' ? 'Game Master' : 'Player'" />
                    </div>

                    <!-- Input Area -->
                    <div class="p-3 border-t flex gap-2">
                        <Input placeholder="Message..." class="h-9" />
                        <Button size="icon" class="h-9 w-9">
                            <Send class="w-4 h-4" />
                        </Button>
                    </div>
                </div>

                <!-- Lists & Groups -->
                <Card>
                    <CardHeader>
                        <CardTitle>Participants</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div class="space-y-4">
                            <div v-for="i in 3" :key="i" class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <Avatar>
                                        <AvatarFallback>P{{ i }}</AvatarFallback>
                                    </Avatar>
                                    <div>
                                        <p class="text-sm font-medium">Player {{ i }}</p>
                                        <p class="text-xs text-muted-foreground">Level 5 Rogue</p>
                                    </div>
                                </div>
                                <Button variant="ghost" size="icon">
                                    <Settings class="w-4 h-4" />
                                </Button>
                            </div>
                        </div>
                    </CardContent>
                </Card>

            </div>
        </section>

    </div>
</template>
