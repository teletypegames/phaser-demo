// game.js

const SCREEN_W = 640;
const SCREEN_H = 480;
const MESSAGE = 'TELETYPE GAMES';
const CHAR_W = 40;
const WAVE_AMPLITUDE = 28;

const PALETTE = ['#1a1c2c', '#5d275d', '#b13e53', '#ef7d57', '#ffcd75'];

class DemoScene extends Phaser.Scene {
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
