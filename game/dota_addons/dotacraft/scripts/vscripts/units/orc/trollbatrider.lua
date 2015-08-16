-- NOTE: OnPhaseStart preventing to cast on ground units ?!
function SpellStart( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	ability:ApplyDataDrivenModifier(caster, caster, 'modifier_unstable_concoction', {})
	caster:EmitSound('Hero_Huskar.Life_Break') 
	caster:MoveToPosition(target:GetAbsOrigin())
	Timers:CreateTimer(function()
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 20, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			if enemy == target then
				caster.target = target
				caster:ForceKill(true)
				return
			end
		end
		return 0.03
	end)
end

function ModDeath( event )
	local caster = event.caster
	local target = caster.target
	local ability = event.ability
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = ability:GetSpecialValueFor('full_damage_amount'),
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	})
	local radius = ability:GetSpecialValueFor('partial_damage_radius')
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		if GetMovementCapability(enemy) == 'air' then
			ApplyDamage({
				victim = target,
				attacker = caster,
				damage = ability:GetSpecialValueFor('partial_damage_amount'),
				damage_type = ability:GetAbilityDamageType(),
				ability = ability
			})
		end
	end
	caster:EmitSound('Hero_Techies.Suicide')
	caster:ForceKill(true)
	ParticleManager:CreateParticle('particles/units/heroes/hero_techies/techies_suicide.vpcf', PATTACH_ABSORIGIN, target)
end