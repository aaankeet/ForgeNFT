'use client';
import {
	useContractRead,
	useContractWrite,
	useContractReads,
	useAccount,
} from 'wagmi';
import {
	assemblerAbi,
	assemblerAddress,
	materialsAddress,
	materialsAbi,
} from '../constants';
import { AiFillLeftCircle, AiFillRightCircle } from 'react-icons/ai';
import { useState } from 'react';
import { ethers } from 'ethers';
import Image from 'next/image';
import basicSword from '../../../public/basicSword.png';
import basicShield from '../../../public/basicShield.png';
import stoneHammer from '../../../public/stoneHammer.png';
import metalSword from '../../../public/metalSword.png';
import metalArmor from '../../../public/metalArmor.png';
import katana from '../../../public/katana.png';
import goldArmor from '../../../public/goldArmor.jpg';

const Assembler = () => {
	const { address, isConnected } = useAccount();

	const [currentIndex, setCurrentIndex] = useState(0);
	const [itemId, setItemId] = useState(0);

	const items = [
		'Basic-Sword',
		'Basic-Shield',
		'Stone-Hammer',
		'Metal-Sword',
		'Metal-Armor',
		'Katana',
		'Gold-Armor',
	];
	const rawMaterials = ['1. Wood', '2. Stone', '3. Iron', '4. Gold'];

	const [isForging, setIsForging] = useState(false);

	const images = [
		basicSword,
		basicShield,
		stoneHammer,
		metalSword,
		metalArmor,
		katana,
		goldArmor,
	];

	const [forgeCost, setForgeCost] = useState(0);
	const {
		write: forge,
		isSuccess,
		isLoading,
	} = useContractWrite({
		address: assemblerAddress,
		abi: assemblerAbi,
		functionName: 'forge',
	});

	const { data: cost, isFetched } = useContractRead({
		address: assemblerAddress,
		abi: assemblerAbi,
		functionName: 'FORGE_COST',
	});

	const { data: userBalance, isFetched: balanceFetched } = useContractReads({
		contracts: [
			{
				address: materialsAddress,
				abi: materialsAddress,
				functionName: 'balanceOf',
				args: [address, 4],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 5],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 6],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 7],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 8],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 9],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 10],
			},
		],
		onError(error) {
			console.log('Error:', error);
		},
	});

	const moveLeft = () => {
		setCurrentIndex((prevIndex) =>
			prevIndex === 0 ? images.length - 1 : prevIndex - 1
		);
		setItemId(currentIndex - 1);
	};
	const moveRight = () => {
		setCurrentIndex((prevIndex) =>
			prevIndex === images.length - 1 ? 0 : prevIndex + 1
		);
		setItemId(currentIndex + 1);
	};

	const getItem = () => {
		if (currentIndex === 0) {
			return 'Basic-Sword';
		} else if (itemId === 1) {
			return 'Basic-Shield';
		} else if (itemId === 2) {
			return 'Stone-Hammer';
		} else if (itemId === 3) {
			return 'Metal-Sword';
		} else if (itemId === 4) {
			return 'Metal-Armor';
		} else if (itemId === 5) {
			return 'Katana';
		} else {
			return 'Gold-Armor';
		}
	};

	const isFirstImage = currentIndex === 0;
	const isLastImage = currentIndex === images.length - 1;

	return (
		<div>
			<h1 className='text-center text-5xl font-bold bg-gradient-to-r from-yellow-200 to-pink-300 via-orange-200 text-transparent bg-clip-text py-2 '>
				Forge`EM: Assemble the Ultimate Arsenal
			</h1>
			<p className='text-gray-500 text-xl text-center py-3'>
				Unlock the full potential of your raw material NFTs by forging
				them into extraordinary <br /> weapons and legendary artifacts,
				crafting a new realm <br />
				of greatness.
			</p>

			<div className='py-3'>
				<div className='flex justify-center gap-3'>
					<button
						className={`focus:outline-none ${
							isFirstImage ? 'invisible' : 'visible'
						}`}
						onClick={moveLeft}
					>
						<AiFillLeftCircle className='text-4xl text-white' />
					</button>
					<div className='relative'>
						{images.map((image, index) => (
							<Image
								key={index}
								alt=''
								src={image}
								width={300}
								height={100}
								className={`rounded ${
									index === currentIndex ? '' : 'hidden'
								}`}
							/>
						))}
					</div>

					<button
						className={`focus:outline-none ${
							isLastImage ? 'invisible' : 'visible'
						}`}
						onClick={moveRight}
					>
						<AiFillRightCircle className='text-4xl text-white ' />
					</button>
				</div>
				<h1 className=' text-xl text-gray-500 font-bold text-center py-2'>
					{getItem()}
				</h1>
			</div>
			<h1 className='text-white text-center text-xl font-bold py-3'>
				Forge Cost: {ethers.formatEther(cost?.toString(), 18)} ETH
			</h1>

			<div>
				{address && userBalance && balanceFetched && (
					<div className='flex justify-center pt-4'>
						<table className='border-collapse  border-gray-300 '>
							<tHead>
								<tr>
									<th className='text-zinc-400 text-2xl px-5'>
										Requirements
									</th>
									<th className='text-zinc-400 text-2xl  px-5'>
										Your Balance
									</th>
								</tr>
							</tHead>
							<tbody>
								{rawMaterials.map((m, index) => (
									<tr key={index + 1}>
										<td className='text-gray-500 text-xl px-5'>
											{m}
										</td>
										<td className='text-gray-500 text-xl px-5'>
											{userBalance[
												index
											]?.result?.toString()}
										</td>
									</tr>
								))}
							</tbody>
						</table>
					</div>
				)}
			</div>
		</div>
	);
};
export default Assembler;
