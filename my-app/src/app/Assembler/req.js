import basicSword from '../../../public/basicSword.png';
import basicShield from '../../../public/basicShield.png';
import stoneHammer from '../../../public/stoneHammer.png';
import metalSword from '../../../public/metalSword.png';
import metalArmor from '../../../public/metalArmor.png';
import katana from '../../../public/katana.png';
import goldArmor from '../../../public/goldArmor.jpg';

const images = [
	basicSword,
	basicShield,
	stoneHammer,
	metalSword,
	metalArmor,
	katana,
	goldArmor,
];

const rawMaterials = ['1. Wood', '2. Stone', '3. Iron', '4. Gold'];

const req = [
	[2, 0, 1, 0],
	[2, 1, 2, 0],
	[1, 2, 0, 0],
	[0, 0, 3, 0],
	[0, 0, 5, 0],
	[1, 1, 5, 1],
	[0, 0, 2, 5],
];

module.exports = {
	basicSword,
	basicShield,
	stoneHammer,
	metalSword,
	metalArmor,
	katana,
	goldArmor,
	req,
	rawMaterials,
	images,
};
