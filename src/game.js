/**
 * The Phaser demo: the letters of "TELETYPE GAMES" ride a sine wave with drop
 * shadows, cycling through a five-colour palette.
 * @module
 */

/** Game width in pixels. */
const SCREEN_W = 640;
/** Game height in pixels. */
const SCREEN_H = 480;
/** The text that waves. */
const MESSAGE = 'TELETYPE GAMES';
/** Horizontal distance between two letters, in pixels. */
const CHAR_W = 40;
/** Height of the wave, in pixels up and down. */
const WAVE_AMPLITUDE = 28;

/** The colours the letters cycle through. */
const PALETTE = ['#1a1c2c', '#5d275d', '#b13e53', '#ef7d57', '#ffcd75'];

/** The only scene: spawns the letters and moves them every frame. */
class DemoScene extends Phaser.Scene {
	/** Spawns every letter with its shadow, centred on the screen. */
	create() {
		const totalW = MESSAGE.length * CHAR_W;
		const startX = (SCREEN_W - totalW) / 2 + CHAR_W / 2;

		this.letters = MESSAGE.split('').map((ch, i) => {
			const style = { fontFamily: 'monospace', fontSize: '48px', fontStyle: 'bold' };

			const shadow = this.add.text(startX + i * CHAR_W + 4, SCREEN_H / 2 + 4, ch, style)
				.setOrigin(0.5).setColor('#000000').setAlpha(0.7);
			const text = this.add.text(startX + i * CHAR_W, SCREEN_H / 2, ch, style)
				.setOrigin(0.5).setColor(PALETTE[i % PALETTE.length]);

			return { shadow, text };
		});
	}

	/**
	 * Moves every letter along the wave and shifts the letters' colours.
	 * @param {number} time the time since the game started, in milliseconds
	 */
	update(time) {
		const t = time / 400;
		this.letters.forEach(({ shadow, text }, i) => {
			const y = SCREEN_H / 2 + Math.sin(t + i * 0.4) * WAVE_AMPLITUDE;
			text.y = y;
			shadow.y = y + 4;
			text.setColor(PALETTE[(i + Math.floor(t * 2)) % PALETTE.length]);
		});
	}
}

new Phaser.Game({
	type: Phaser.AUTO,
	width: SCREEN_W,
	height: SCREEN_H,
	backgroundColor: '#000000',
	parent: 'game',
	scene: DemoScene,
	title: 'Teletype Games'
});
