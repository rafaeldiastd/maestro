import { DiceRoller } from '@dice-roller/rpg-dice-roller'

const roller = new DiceRoller()

export function useDiceRoll() {

    const roll = (formula, label = '', context = 'generic') => {
        try {
            // Support "Formula # DamageFormula" syntax
            let mainFormula = formula
            let damageFormula = null

            if (formula.includes('#')) {
                const parts = formula.split('#')
                mainFormula = parts[0].trim()
                damageFormula = parts[1].trim()
            }

            const result = roller.roll(mainFormula)

            // Extract details for display
            // RPG Dice Roller output structure is complex. 
            // result.total is the sum.
            // result.rolls is the breakdown.
            // We'll return a structured object for our Chat system.

            return {
                type: 'roll',
                formula: mainFormula,
                damageFormula: damageFormula,
                total: result.total,
                output: result.toString(), // e.g. "4d6: [4, 1, 6, 2] = 13"
                breakdown: result.rolls[0], // Simplified access to first group if simple roll
                rolls: result.rolls, // Full breakdown for complex rolls (Advantage/Disadvantage)
                label: label,
                context: context, // 'attack', 'spell', 'check', 'save', 'generic'
                timestamp: Date.now()
            }
        } catch (e) {
            console.error('Roll error:', e)
            return null
        }
    }

    return {
        roll
    }
}
