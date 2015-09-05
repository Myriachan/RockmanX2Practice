arch snes.cpu

// LoROM org macro - see bass's snes-cpu.asm "seek" macro
macro reorg n
	org (({n} & 0x7F0000) >> 1) | ({n} & 0x7FFF)
	base {n}
endmacro

// Allows going back and forth
define savepc push origin, base
define loadpc pull base, origin

// Copy the original ROM
{reorg $008000}
incbin "Rockman X 2 (J).smc"


// Constants
// Version tags
eval version_major 1
eval version_minor 2
eval version_revision 0
// RAM addresses
eval title_screen_option $7E003C
eval controller_1_current $7E00A8
eval controller_1_unknown $7E00AA
eval controller_1_unknown2 $7E00AC
eval controller_1_new_presses $7E00AE
eval current_play_state $7E00D2
eval countdown_play_state $7E00D6
eval unknown_level_flag $7E1EBF
eval state_vars $7E1FA0
eval current_level $7E1FAD
eval xhunter_level $7E1FAE
eval life_count $7E1FB3
// SRAM addresses for saved states
eval sram_dma_bank $770000
// Mode IDs (specific to this hack)
eval mode_id_anypercent 0  // Any%, which just means Zero isn't saved.
// Route IDs
eval route_id_stag3rd 0    // Route where Flame Stag is killed 3rd.
// Level IDs
eval level_id_intro 0
eval level_id_moth 1
eval level_id_sponge 2
eval level_id_crab 3
eval level_id_stag 4
eval level_id_centipede 5
eval level_id_snail 6
eval level_id_ostrich 7
eval level_id_gator 8
eval level_id_violen 9
eval level_id_serges 10
eval level_id_agile 11
eval level_id_teleporter 12
eval level_id_sigma 13  // fake
// Other constants
eval play_state_normal $04
eval play_state_death $06
eval select_button $2000
eval stage_select_id_hunter $FF
eval stage_select_id_x $80
eval unknown_level_flag_value_normal $01
eval unknown_level_flag_value_xhunter $FF


{savepc}
	{reorg $00C622}
	// Always allow exiting levels
patch_exit_hack:
	lda.b #$40
	rts
{loadpc}


{savepc}
	{reorg $00BF96}
	// Jump to choose_level_hook
patch_choose_level_hook:
	jml choose_level_hook
{loadpc}


{savepc}
	{reorg $00BD29}
	// Don't play the Counter-Hunter stage select music.  It's annoying.
	// The above patch causes it to always play otherwise.
patch_dont_play_counter_hunter_music:
	ora.b #0
{loadpc}


{savepc}
	{reorg $0096D4}
patch_skip_intro:
	// Skip the intro.  If they want to play the intro, they can select the
	// Maverick icon at stage select (what would normally be the Counter-
	// Hunter choice).
	bra $0096F2
{loadpc}


{savepc}
	{reorg $00BD25}
	// When loading stage select, always reset to a default state with all
	// bosses undefeated, so that they all appear available.
	// Yes, this patch is immediately before the Counter-Hunter music one.
patch_stage_select_reset_state:
	jsl stage_select_reset_state
{loadpc}


{savepc}
	{reorg $0099AD}
	// Infinite lives.  Don't decrement the life counter, and don't do
	// anything if you die with zero lives.
patch_infinite_lives:
	bra $0099B2
{loadpc}


{savepc}
	// These prevent the teleporters in the "boss repeat"/"teleporter" stage
	// from disabling themselves after beating a boss.  This allows the runner
	// to repeat the boss as much as she wants.
	// Unfortunately, each boss has their own assembly code to patch.
	//
	// Morph Moth
	{reorg $298D99}
	nop  // NOP's TSB of $01 into $7E1FD9
	nop
	nop
	// Wire Sponge
	{reorg $04A752}
	nop  // NOP's TSB of $02 into $7E1FD9
	nop
	nop
	// Bubble Crab
	{reorg $07CA69}
	nop  // NOP's TSB of $04 into $7E1FD9
	nop
	nop
	// Flame Stag
	{reorg $04C2F1}
	nop  // NOP's TSB of $08 into $7E1FD9
	nop
	nop
	// Magna Centipede
	{reorg $04B1F3}
	nop  // NOP's TSB of $10 into $7E1FD9
	nop
	nop
	// Crystal Snail
	{reorg $07BD6B}
	nop  // NOP's TSB of $20 into $7E1FD9
	nop
	nop
	// Overdrive Ostrich
	{reorg $08F0AE}
	nop  // NOP's TSB of $40 into $7E1FD9
	nop
	nop
	// Wheel Gator
	{reorg $03BFDF}
	nop  // NOP's TSB of $80 into $7E1FD9
	nop
	nop
{loadpc}


{savepc}
	{reorg $009A6C}
	// Don't show the ending after beating Sigma; instead, just show the
	// password screen as usual. =)
patch_disable_ending:
	bra $009A71
{loadpc}


{savepc}
	{reorg $08BF41}
	// Allow pressing select + start to simulate death.
	// This hook activates when the game is checking to see whether the
	// player is pressing L or R to change weapons.
patch_death_command_hook:
	jml death_command_hook
{loadpc}

{savepc}
	{reorg $0090E2}
	// Change where Rockman starts on the title screen, which is hardcoded.
patch_title_rockman_default_location:
	lda.b #$96
{loadpc}


{savepc}
	// Make the number of title screen options 4 instead of 3.
	{reorg $00915F}
patch_title_num_options_up:
	lda.b #3
	{reorg $00916A}
patch_title_num_options_down:
	cmp.b #4
{loadpc}


{savepc}
	// Make the jump table for four options work correctly.
	// We delete the Password option, and the first three options all start
	// the game.  We simply read out title_screen_option later to distinguish
	// among those.  So a simple compare will suffice here!
	{reorg $0091FF}
patch_title_option_jump_table:
	cmp.b #3
	beq $00923A
	bra $00920A
{loadpc}


{savepc}
	{reorg $009173}
	// Call our routine when the title screen cursor moves.
patch_title_cursor_moved:
	jml title_cursor_moved
{loadpc}


{savepc}
	// 2 KB available here.
	{reorg $03F800}

choose_level_hook:
	// Entering with 8-bit A, unknown-size X/Y
	phx
	phy
	php
	phb
	rep #$10

	// Remap choice into route_table index (value 0-9, doubled to 0-19 based
	// on whether select is held).

	// First check for special options (X, counter-hunter)
	cmp.b #{stage_select_id_hunter}
	beq .hunter_level
	ora.b #0
	bmi .x_icon

	// For the normal cases, look the index into the route table.
	xba
	lda.b #0
	xba
	tax
	lda.l level_id_to_route_table_map, x
	bra .select_check

.hunter_level:
	lda.b #8
	bra .select_check
.x_icon:
	lda.b #3
	// Fall through to .select_check.

.select_check:
	// Holding the select button?
	pha
	lda.w {controller_1_current} + 1
	and.b #{select_button} >> 8
	beq .do_route_lookup

	// If so, add 10 to the index into the route table.
	pla
	clc
	adc.b #10
	pha

.do_route_lookup:
	// Switch to 16-bit and re-save the level as 16-bit, this time in Y.
	pla
	rep #$20
	and.w #$00FF
	tay

	// Look up the pointer to the route table for the current mode.
	// The title screen option is left alone from back then.
	lda.w {title_screen_option}
	and.w #$00FF
	asl
	tax
	lda.l route_metatable, x

	// I need a temporary variable in memory for the add, and I can't find
	// one, so I just overwrite something I see used recently and save it to
	// the stack.  >.<
	ldx.b $29
	phx
	sta.b $29

	// Look up the route data pointer for the chosen level from that table.
	tya
	asl  // Clears carry because the value is small.
	adc.b $29

	// Restore unknown destroyed variable before continuing.
	ply
	sty.b $29

	tax
	// The table is offset by 1, so the + 2 that'd be needed to skip over the
	// table's entry for stage select itself is nullified by being offset.
	lda.l (route_table_bank_marker & $FF0000) + 2 - 2, x

	// If the value is 0, treat it as the X option.
	beq .x_option

	// Copy the state data into place.  MVN changes the bank register, but it
	// doesn't affect anything we're up to.
	tax
	lda.w #64 - 1
	ldy.w #{state_vars}
	mvn {state_vars} >> 16 = state_data_bank_marker >> 16

	// Read back the level ID.  The bank MVN set is compatible with this.
	sep #$20
	lda.w {current_level}

	// We need to set an unknown flag based on whether a stage is a Counter-
	// Hunter level.  This is easy for the first four levels; just check the
	// final level ID for being 9 or greater.  The fifth level, however, is
	// just Magna Centipede's, so we have to be a bit more creative.  We check
	// how many Counter Hunter levels you've beaten.  If you're on Magna
	// Centipede's level and have beaten 4 Counter-Hunter levels, you're in a
	// Counter-Hunter level.  (The game doesn't care which you chose.)
	cmp.b #9
	bcs .loading_hunter_level
	cmp.b #5
	bne .loading_normal_level
	lda.w {xhunter_level}
	cmp.b #4
	bcc .loading_normal_level

.loading_hunter_level:
	lda.b #{unknown_level_flag_value_xhunter}
	bra .loading_level

.loading_normal_level:
	lda.b #{unknown_level_flag_value_normal}

.loading_level:
	sta.w {unknown_level_flag}
	plb
	plp
	ply
	plx
	jml $00BFC9

.x_option:
	// A is still 16-bit, but we do a PLP here.
	plb
	plp
	ply
	plx
	jml $00BFA6


// The player is moving the cursor on the title screen.  First things
// first: we now have a 4-element table instead of a 3-element table,
// so we have to move the table order to expand it.  As is typical, it's
// in bank 6, but it's only 4 bytes.
title_cursor_moved:
	lda.w title_rockman_location, x
	sta.w $7E09E0

	// Draw the currently-highlighted string.
	lda.b #$10  // Is this store required?
	sta.b $02

	lda.w {title_screen_option}
	rep #$20
	and.w #$00FF
	asl
	tax
	lda.w title_screen_string_table, x
	sta.b $10
	sep #$20

	// Engineer a near return to $009181.
	pea ($009181 - 1) & $FFFF
	// Jump to the middle of draw_string.
	jml $00867B


// Called when stage select is first loaded.  Reset the state to all bosses
// undefeated for display purposes.  We'll load a better state when a stage
// is selected.  This also means that we don't need to load a route-specific
// state here, so just always use Any% Stag 3rd.
stage_select_reset_state:
	// The original function destroys A and X, and sets A and X to 8-bit, so I
	// don't have to be too careful here.  I'm going to assume Y isn't needed.
	rep #$30

	phb  // MVN modifies the bank register
	lda.w #64 - 1
	ldx.w #state_data_anypercent_stag3rd.intro
	ldy.w #{state_vars}
	mvn {state_vars} >> 16 = state_data_bank_marker >> 16
	plb

	// Always show the Counter-Hunter option, which is our intro stage.  We do
	// this by writing 8 (number of dead bosses) to this variable, whatever it
	// is, and by setting the zero flag before returning.
	sep #$30  // original function set X and Y to 8-bit as well.
	lda.b #8
	sta.b $2C
	cmp.b #8
	rtl


// Called when the game is checking for L/R for changing weapons.
// Select+Start is a request to kill Rockman X, in order to restart.
// I hook this particular location because it more or less guarantees that the
// game engine is in a state in which I can do this.
death_command_hook:
	// Entering with 8-bit A and 8-bit X.

	// Check for Select + Start.
	lda.w {controller_1_current} + 1
	and.b #$30
	cmp.b #$30
	bne .original_code

	// Check for being in the normal state, so as to not activate this code
	// unless we're in the expected state.
	lda.w {current_play_state}
	cmp.b #{play_state_normal}
	bne .original_code

	// OK, kill him.  The countdown $01 fades out immediately.  $F0 is the
	// normal countdown for death.
	lda.b #{play_state_death}
	sta.w {current_play_state}
	lda.b #$01
	sta.w {countdown_play_state}

	// Jump back to an RTS.  If neither L nor R is being pressed, the game
	// branches to this RTS, so this is the right place to go.  Labeled
	// "not_pressing_R" in sub_8BECC in my disassembly.
.jump_to_rts:
	bra .not_pressing_R  // save 2 bytes by jumping to other jml

.original_code:
	// The replaced code checks for R being pressed, so we copy that here.
	// We need to reload A from D+$3A, though, because we destroyed it above.
	lda.b $3A
	bit.b #$10
	beq .not_pressing_R
	jml $08BF45
.not_pressing_R:
	jml $08BFAC


// Use this label >> 16 as the bank for the following route and mode tables.
route_table_bank_marker:

level_id_to_route_table_map:
	db $FF, 2, 1, 7, 4, 5, 10, 6, 9

route_table_anypercent_stag3rd:
	// For stage select
	dw state_data_anypercent_stag3rd.sponge
	// Without select button
	dw state_data_anypercent_stag3rd.sponge
	dw state_data_anypercent_stag3rd.moth
	dw 0  // placeholder for the X
	dw state_data_anypercent_stag3rd.stag
	dw state_data_anypercent_stag3rd.centipede
	dw state_data_anypercent_stag3rd.ostrich
	dw state_data_anypercent_stag3rd.crab
	dw state_data_anypercent_stag3rd.intro
	dw state_data_anypercent_stag3rd.gator
	dw state_data_anypercent_stag3rd.snail
	// With select button
	dw state_data_anypercent_stag3rd.violen               // \   These ones are replaced
	dw state_data_anypercent_stag3rd.serges               //  \  versus normal.
	dw state_data_anypercent_stag3rd.agile                //   > X becomes Agile.
	dw state_data_anypercent_stag3rd.teleporter           //  /
	dw state_data_anypercent_stag3rd.sigma                // /
	dw state_data_anypercent_stag3rd.ostrich
	dw state_data_anypercent_stag3rd.crab
	dw state_data_anypercent_stag3rd.intro
	dw state_data_anypercent_stag3rd.gator
	dw state_data_anypercent_stag3rd.snail

route_table_100percent_ostrich3rd:
	// For stage select
	dw state_data_100percent_ostrich3rd.sponge
	// Without select button
	dw state_data_100percent_ostrich3rd.sponge
	dw state_data_100percent_ostrich3rd.moth
	dw 0  // placeholder for the X
	dw state_data_100percent_ostrich3rd.stag
	dw state_data_100percent_ostrich3rd.centipede
	dw state_data_100percent_ostrich3rd.ostrich
	dw state_data_100percent_ostrich3rd.crab
	dw state_data_100percent_ostrich3rd.intro
	dw state_data_100percent_ostrich3rd.gator
	dw state_data_100percent_ostrich3rd.snail
	// With select button
	dw state_data_100percent_ostrich3rd.violen            // \   These ones are replaced
	dw state_data_100percent_ostrich3rd.serges            //  \  versus normal.
	dw state_data_100percent_ostrich3rd.agile             //   > X becomes Agile.
	dw state_data_100percent_ostrich3rd.teleporter        //  /
	dw state_data_100percent_ostrich3rd.sigma             // /
	dw state_data_100percent_ostrich3rd.ostrich
	dw state_data_100percent_ostrich3rd.crab
	dw state_data_100percent_ostrich3rd.intro
	dw state_data_100percent_ostrich3rd.gator
	dw state_data_100percent_ostrich3rd.snail

route_table_anypercent_ostrich3rd:
	// For stage select
	dw state_data_anypercent_ostrich3rd.sponge
	// Without select button
	dw state_data_anypercent_ostrich3rd.sponge
	dw state_data_anypercent_ostrich3rd.moth
	dw 0  // placeholder for the X
	dw state_data_anypercent_ostrich3rd.stag
	dw state_data_anypercent_ostrich3rd.centipede
	dw state_data_anypercent_ostrich3rd.ostrich
	dw state_data_anypercent_ostrich3rd.crab
	dw state_data_anypercent_ostrich3rd.intro
	dw state_data_anypercent_ostrich3rd.gator
	dw state_data_anypercent_ostrich3rd.snail
	// With select button
	dw state_data_anypercent_ostrich3rd.violen            // \   These ones are replaced
	dw state_data_anypercent_ostrich3rd.serges            //  \  versus normal.
	dw state_data_anypercent_ostrich3rd.agile             //   > X becomes Agile.
	dw state_data_anypercent_ostrich3rd.teleporter        //  /
	dw state_data_anypercent_ostrich3rd.sigma             // /
	dw state_data_anypercent_ostrich3rd.ostrich
	dw state_data_anypercent_ostrich3rd.crab
	dw state_data_anypercent_ostrich3rd.intro
	dw state_data_anypercent_ostrich3rd.gator
	dw state_data_anypercent_ostrich3rd.snail


route_metatable:
	dw route_table_anypercent_stag3rd
	dw route_table_anypercent_ostrich3rd
	dw route_table_100percent_ostrich3rd


{loadpc}


{savepc}
	// 640 bytes available in bank 6, an extremely-critical bank.
	{reorg $006FD80}

initial_menu_strings:
	// I'm too lazy to rework the compressed font, so I use this to overwrite
	// the ` character in VRAM.  The field used for the "attribute" of the
	// "text" just becomes the high byte of each pair of bytes.
	macro tilerow vrambase, rownum, col7, col6, col5, col4, col3, col2, col1, col0
		db 1, (({col7} & 2) << 6) | (({col6} & 2) << 5) | (({col5} & 2) << 4) | (({col4} & 2) << 3) | (({col3} & 2) << 2) | (({col2} & 2) << 1) | ({col1} & 2) | (({col0} & 2) >> 1)
		dw (({vrambase}) + (({rownum}) * 2)) >> 1
		db (({col7} & 1) << 7) | (({col6} & 1) << 6) | (({col5} & 1) << 5) | (({col4} & 1) << 4) | (({col3} & 1) << 3) | (({col2} & 1) << 2) | (({col1} & 1) << 1) | ({col0} & 1)
	endmacro

	macro optionset label, attrib1, attrib2, attrib3, attrib4
		db .option1_{label}_end - .option1_{label}_begin, {attrib1}
		dw $1492 >> 1
	.option1_{label}_begin:
		db "ANY` - STAG 3RD"
	.option1_{label}_end:

		db .option2_{label}_end - .option2_{label}_begin, {attrib2}
		dw $1512 >> 1
	.option2_{label}_begin:
		db "ANY` - OSTRICH 3RD"
	.option2_{label}_end:

		db .option3_{label}_end - .option3_{label}_begin, {attrib3}
		dw $1592 >> 1
	.option3_{label}_begin:
		db "100` - OSTRICH 3RD"
	.option3_{label}_end:

		db .option4_{label}_end - .option4_{label}_begin, {attrib4}
		dw $1612 >> 1
	.option4_{label}_begin:
		db "OPTION MODE"
	.option4_{label}_end:

		db 0
	endmacro

	{tilerow $0600, 0,   0,2,3,0,0,0,2,3}
	{tilerow $0600, 1,   2,3,2,3,0,2,3,0}
	{tilerow $0600, 2,   3,1,3,0,1,3,0,0}
	{tilerow $0600, 3,   0,3,0,1,3,0,0,0}
	{tilerow $0600, 4,   0,0,1,3,0,1,3,0}
	{tilerow $0600, 5,   0,2,3,0,2,3,2,3}
	{tilerow $0600, 6,   2,3,0,0,3,2,3,0}
	{tilerow $0600, 7,   3,0,0,0,0,3,0,0}

	// Menu text.  I've added an extra option versus the original and moved it
	// one tile to the left for better centering.  I also added the edition
	// text to the top.
	db .edition_end - .edition_begin, $28
	dw $138E >> 1
.edition_begin:
	db "- Practice Edition -"
.edition_end:

// Option set 1 can be overlapped with the tail of initial_menu_strings.
option_set_1:
	{optionset s1, $24, $20, $20, $20}
	db 0

option_set_2:
	{optionset s2, $20, $24, $20, $20}
	db 0
option_set_3:
	{optionset s3, $20, $20, $24, $20}
	db 0
option_set_4:
	{optionset s4, $20, $20, $20, $24}
	db 0

// Pointers to the option strings.
title_screen_string_table:
	dw option_set_1
	dw option_set_2
	dw option_set_3
	dw option_set_4

// Replacement copyright string.  @ in the X2 font is the copyright symbol.
copyright_string:
	db .rockman_x2_end - .rockman_x2_start, $20
	dw $1356 >> 1
.rockman_x2_start:
	db "ROCKMAN X2"
.rockman_x2_end:
	// The original drew a space then went back and drew a copyright symbol
	// over the space.  I don't see a need to do that - I'll draw a copyright
	// symbol in the first place.
	db .capcom_end - .capcom_start, $20
	dw $13CC >> 1
.capcom_start:
	db "@ CAPCOM CO.,LTD.1994"
.capcom_end:
	// My custom message.
	db 1, $60
	dw $1486 >> 1
	db '"'
	db .practice_end - .practice_start, $20
	dw $1488 >> 1
.practice_start:
	db "PRACTICE EDITION",'"'," BY MYRIA"
.practice_end:
	db .version_end - .version_start, $20
	dw $14CE >> 1
.version_start:
	db "2014-2015 Ver. "
	db $30 + {version_major}, '.', $30 + {version_minor}, $30 + {version_revision}
.version_end:
	// Terminates sequence of VRAM strings.
	db 0

// Y coordinates of Rockman corresponding to each option.
title_rockman_location:
	db $96, $A6, $B6, $C6

{loadpc}


{savepc}
	// Overwrite the copyright string pointer.
	{reorg $068C7B}
	dw copyright_string

	// Overwrite the title screen string pointers with this one.
	{reorg $068C8F}
	dw initial_menu_strings
	dw initial_menu_strings
	dw initial_menu_strings

{loadpc}



{savepc}
	// 4 KB available here.
	{reorg $04F000}
// Use this label >> 16 as the bank for state data blocks.
state_data_bank_marker:

// State data for Any % for the route with Flame Stag as the 3rd boss
state_data_anypercent_stag3rd:
.intro:
	//  0. Intro stage.  Copy of this data for posterity.  We actually
	// use Wire Sponge (i.e., the post-intro) data for the intro, so
	// that the Counter-Hunter dialogue doesn't repeat.
	//db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	//db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	//db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	//db $00,$10,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
	// Same as Wire Sponge data, except level ID is hacked to 0.
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40
	db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $00,$10,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.sponge:
	//  1. Wire Sponge's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$40
	db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $00,$10,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.gator:
	//  2. Wheel Gator's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $40,$12,$01,$80,$00,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.stag:
	//  3. Flame Stag's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $42,$14,$01,$A0,$00,$1B,$01,$04,$07,$00,$00,$00,$00,$00,$00,$58
.centipede:
	//  4. Magna Centipede's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$00,$00,$DC,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$DC
	db $62,$16,$01,$A2,$00,$24,$03,$00,$01,$00,$00,$00,$00,$00,$00,$58
.snail:
	//  5. Crystal Snail's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$00,$00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$00,$00,$DC
	db $72,$18,$01,$AA,$00,$51,$06,$00,$03,$00,$00,$00,$00,$00,$00,$58
.ostrich:
	//  6. Overdrive Ostrich's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$00,$00,$DC,$00,$00,$00,$00
	db $00,$DC,$00,$00,$00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$DC
	db $73,$1A,$01,$BA,$00,$2D,$00,$00,$07,$00,$00,$00,$00,$00,$00,$58
.crab:
	//  7. Bubble Crab's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$00,$00,$DC,$00,$00,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$DC
	db $7B,$1C,$01,$BE,$00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.moth:
	//  8. Morph Moth's stage
	// NOTE: $1FAF (byte index $0F here) was hacked from $40 to $E0
	// in order to stop Dr. Cain from saying that he found the Counter
	// Hunters' lair every time you beat Morph Moth because he's the
	// 8th boss.                                                   vvv
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$E0
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$DC
	db $FB,$1E,$01,$FE,$00,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.violen:
	//  9. Violen's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.serges:
	// 10. Serges's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,$01,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.agile:
	// 11. Agile's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$02,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.teleporter:
	// 12. Boss Repeats ("Teleporter" stage)
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$03,$E0
	db $00,$80,$00,$04,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.sigma:
	// 13. Sigma (Magna Centipede redux)
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$04,$E0
	db $00,$80,$00,$04,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$58


// State data for Any % for the route with Overdrive Ostrich as the 3rd boss
state_data_anypercent_ostrich3rd:
.intro:
	//  0. Intro stage.  Copy of this data for posterity.  We actually
	// use Wire Sponge (i.e., the post-intro) data for the intro, so
	// that the Counter-Hunter dialogue doesn't repeat.
	// db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	// db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	// db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	// db $00,$10,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
	// Same as Wire Sponge data, except level ID is hacked to 0.
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40
	db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $00,$10,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.sponge:
	//  1. Wire Sponge's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$40
	db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $00,$10,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.gator:
	//  2. Wheel Gator's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $40,$12,$01,$80,$00,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.ostrich:
	//  3. Overdrive Ostrich's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $42,$14,$01,$A0,$00,$2D,$01,$04,$07,$00,$00,$00,$00,$00,$00,$58
.crab:
	//  4. Bubble Crab's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $4A,$16,$01,$A4,$00,$36,$03,$05,$00,$00,$00,$00,$00,$00,$00,$58
.stag:
	//  5. Flame Stag's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$00,$00,$00,$00,$00,$DC,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $CA,$18,$01,$E4,$00,$1B,$00,$06,$00,$00,$00,$00,$00,$00,$00,$58
.moth:
	//  6. Morph Moth's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$00,$00,$00,$00,$DC,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$DC
	db $EA,$1A,$01,$E6,$00,$09,$00,$01,$00,$00,$00,$00,$00,$00,$00,$58
.centipede:
	//  7. Magna Centipede's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$00,$00,$00,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$40,$00,$00,$00,$DC
	db $EE,$1C,$01,$E7,$00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.snail:
	//  8. Crystal Snail's stage - event flag hacked to E0 to stop Dr. Cain speech
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$E0
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$8E,$00,$00,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$C1,$00,$00,$00,$DC
	db $FE,$1E,$01,$EF,$00,$51,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.violen:
	//  9. Violen's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.serges:
	// 10. Serges's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,$01,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.agile:
	// 11. Agile's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$02,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.teleporter:
	// 12. Boss Repeats ("Teleporter" stage)
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$03,$E0
	db $00,$80,$00,$04,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.sigma:
	// 13. Sigma (Magna Centipede redux)
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$04,$E0
	db $00,$80,$00,$04,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$58


// State data for 100 % for the route with Overdrive Ostrich as the 3rd boss
state_data_100percent_ostrich3rd:
.intro:
	//  0. Intro stage.  Copy of this data for posterity.  We actually
	// use Wire Sponge (i.e., the post-intro) data for the intro, so
	// that the Counter-Hunter dialogue doesn't repeat.
	// db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	// db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	// db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	// db $00,$10,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
	// Same as Wire Sponge data, except level ID is hacked to 0.
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40
	db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $00,$10,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.sponge:
	//  1. Wire Sponge's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$40
	db $00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $00,$10,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.gator:
	//  2. Wheel Gator's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $40,$12,$01,$80,$00,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58
.ostrich:
	//  3. Overdrive Ostrich's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $42,$14,$01,$A0,$00,$2D,$01,$04,$07,$00,$00,$00,$00,$00,$00,$58
.crab:
	//  4. Bubble Crab's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $4A,$16,$01,$A4,$00,$36,$03,$05,$80,$00,$00,$00,$00,$00,$00,$58
.stag:
	//  5. Flame Stag's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$00,$00,$00,$00,$00,$DC,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DC
	db $CA,$18,$01,$E4,$00,$1B,$80,$06,$80,$00,$00,$00,$00,$00,$00,$58
.moth:
	//  6. Morph Moth's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$40
	db $00,$00,$00,$02,$00,$01,$8E,$8E,$8E,$00,$00,$00,$00,$DC,$00,$00
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$00,$00,$00,$00,$DC
	db $EA,$1A,$01,$E6,$00,$09,$80,$01,$80,$00,$00,$00,$00,$00,$00,$58
.centipede:
	//  7. Magna Centipede's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$20
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$00,$00,$00,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$00,$00,$DC,$00,$C6,$00,$00,$00,$DC
	db $EE,$1C,$01,$E7,$00,$24,$80,$80,$80,$00,$00,$00,$00,$00,$00,$58
.snail:
	//  8. Crystal Snail's stage - event flag hacked to E0 to stop Dr. Cain speech
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$00,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$80,$C7,$00,$00,$00,$DC
	db $FE,$1E,$01,$EF,$00,$51,$80,$80,$80,$00,$00,$00,$00,$00,$00,$58
.violen:
	//  9. Violen's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$80,$4D,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$80,$80,$80,$00,$00,$00,$00,$00,$00,$58
.serges:
	// 10. Serges's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,$01,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$80,$55,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$80,$80,$80,$00,$00,$00,$00,$00,$00,$58
.agile:
	// 11. Agile's stage
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$02,$E0
	db $00,$00,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$80,$80,$80,$00,$00,$00,$00,$00,$00,$58
.teleporter:
	// 12. Boss Repeats ("Teleporter" stage)
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$03,$E0
	db $00,$80,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$80,$80,$80,$00,$00,$00,$00,$00,$00,$58
.sigma:
	// 13. Sigma (Magna Centipede redux)
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$04,$E0
	db $00,$80,$00,$03,$00,$01,$8E,$8E,$8E,$8E,$00,$DC,$00,$DC,$00,$DC
	db $00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$DC,$00,$5C,$00,$DC,$00,$DC
	db $FF,$20,$01,$FF,$01,$3F,$80,$80,$80,$FF,$00,$00,$00,$00,$00,$58

{loadpc}


{savepc}
	// Hook NMI
	{reorg $00FFEA}
	dw $FFA0
	{reorg $00FFFA}
	dw $FFA0
	{reorg $00FFA0}
	jml nmi_hook

	// Change SRAM size to 256 KB
	{reorg $00FFD8}
	db $08
{loadpc}


{savepc}
	// Saved state hacks
	{reorg $03FA00}
nmi_hook:

	// Rather typical NMI prolog code
	rep #$38
	pha
	phx
	phy
	phd
	phb
	lda.w #$0000
	tcd

	// Don't interfere with NMI as much as possible.
	// Only execute when select is pressed.
	lda.b {controller_1_current}
	bit.w #$2000
	beq .c_skip_lda
	bra .check_controller

.c:
	lda.b {controller_1_current}
.c_skip_lda:
	sta.l $704218
.d:
	rep #$38
	jml $7E200B          // Jump to normal NMI handler in RAM, skipping the
	                     // prolog code, since we already did it.

.check_controller:
	// Clear the bank register so that we know register writes work correctly.
	ldy.w #$0000
	phy
	plb
	plb

	// Mask controller.
	lda.b {controller_1_current}
	and.b {controller_1_unknown2}
	bne .have_controller_1_data
	bra .jmp_b

.have_controller_1_data:
	lda.b {controller_1_current}
	and.w #$2010   // Select + R
	cmp.w #$2010
	beq .select_r_pressed
.jmp_b:
	jmp .b

.select_r_pressed:
	sep #$20

	// Store DMA to SRAM
	ldy.w #0
	ldx.w #0

	sep #$20
.save_dma_reg_loop:
	lda.w $4300, x
	sta.l {sram_dma_bank}, x
	inx
	iny
	cpy.w #$000B
	bne .save_dma_reg_loop
	cpx.w #$007B
	beq .save_dma_regs_done
	inx
	inx
	inx
	inx
	inx
	ldy.w #0
	jmp .save_dma_reg_loop
	// End of DMA to SRAM

.save_dma_regs_done:
	jsr .ppuoff
	lda.b #$80
	sta.w $4310
	jsr .func_dma2

	sep #$20
	rep #$10
	lda.b #$81    // 00 load, 80 save
	sta.w $4310
	lda.b #$39
	sta.w $4311
	jmp .end

.b:
	rep #$20
	lda.b {controller_1_unknown2}
	and.b {controller_1_current}
	bne .have_controller_1_data_2
	sep #$20
	jmp .c

.have_controller_1_data_2:
	lda.b {controller_1_current}
	and.w #$2020   // Select + L
	cmp.w #$2020
	beq .select_l_pressed
	sep #$20
	jmp .c

.select_l_pressed:
	sep #$20

	// Stop sound effects
	stz.w $2141
	stz.w $2142
	stz.w $2143
	lda.b #$F1
	sta.w $2140

	stz.w $420C
	jsr .ppuoff
	stz.w $4310
	jsr .func_dma2

	// Restart music
	rep #$20

	// Rewrite inputs in ram to reflect the loading inputs and not saving inputs
	lda.b {controller_1_current}
	eor.w #$2010
	ora.w #$2020
	sta.b {controller_1_unknown}
	sta.b {controller_1_current}
	sta.b {controller_1_unknown2}

	// Load DMA from SRAM
	ldy.w #0
	ldx.w #0

	sep #$20
.load_dma_regs_loop:
	lda.l {sram_dma_bank}, x
	sta.w $4300, x
	inx
	iny
	cpy.w #$000B
	bne .load_dma_regs_loop
	cpx.w #$007B
	beq .load_dma_regs_done
	inx
	inx
	inx
	inx
	inx
	ldy.w #0
	jmp .load_dma_regs_loop
	// End of DMA from SRAM

	// Continue with WRAM DMA and cleanup
.load_dma_regs_done:
	sep #$20
	rep #$10
	lda.b #$01
	sta.w $4310
	lda.b #$80
	sta.w $2115
	lda.b #$18
	sta.w $4311
	jmp .end

.ppuoff:
	lda.b #$80
	//sta.b $13
	sta.w $2100
	stz.w $4200
	rts

.func_dma1:
	ldx.w #$7500  // SRAM address >> 8
	ldy.w #$0000  // VRAM address >> 1
	lda.b #$80    // size >> 8
	jsr .func_dma1b
	ldx.w #$7600  // SRAM address >> 8
	ldy.w #$4000  // VRAM address >> 1
	lda.b #$80    // size >> 8
	jsr .func_dma1b
	rts

.func_dma1b:
	sty.w $2116
	stz.w $4312
	stx.w $4313
	stz.w $4315
	sta.w $4316
	stz.w $2115
	lda.w $4311
	cmp.b #$39
	bne .skip_2139_write
	lda.w $2139
.skip_2139_write:
	lda.b #$02
	sta.w $420B
	rts

.func_dma2:
	plx
	stx.w $4318          // HDMA current low = 0

	stz.w $2181          // WRAM low = 0
	stz.w $4312          // HDMA start low = 0

	ldy.w #$0071         // Copy to bank 71
	ldx.w #$0000         // Copy 7FFF bytes from 7E0000-7E7FFF
	jsr .func_dma2b
	iny                  // Copy to bank 72
	ldx.w #$0080         // Copy 7FFF bytes from 7E8000-7EFFFF
	jsr .func_dma2b
	iny                  // Copy to bank 73
	ldx.w #$0100         // Copy 7FFF bytes from 7F0000-7F7FFF
	jsr .func_dma2b
	iny                  // Copy to bank 74
	ldx.w #$0180         // Copy 7FFF bytes from 7F8000-7FFFFF
	jsr .func_dma2b

	ldx.w $4318
	phx
	rts

.func_dma2b:
	stz.w $4313          // HDMA start high
	sty.w $4314          // HDMA start bank = Y
	stx.w $2182          // WRAM start high + bank
	lda.b #$80
	sta.w $4311          // Select WRAM for DMA
	sta.w $4316          // Bytes to be transferred, 0x7FFF bytes (FFFF-8000)
	lda.b #$02
	sta.w $420B          // Start DMA
	rts

.end:
	jsr .func_dma1

	lda.b $C3
	sta.w $4200
	lda.b $C4
	sta.w $420C
	lda.b $B4
	sta.w $2100

	lda.w $2142
	sta.l $7EFFFE
	jmp .d

{loadpc}
