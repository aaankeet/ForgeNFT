'use client';

import React, { useEffect, useState } from 'react';
import { AiFillLeftCircle, AiFillRightCircle } from 'react-icons/ai';
import Image from 'next/image';
import wood from '../../public/wood.png';
import stone from '../../public/stone.png';
import iron from '../../public/iron.png';
import gold from '../../public/gold.jpg';
import {
	useContractReads,
	useContractWrite,
	useContractRead,
	useWaitForTransaction,
} from 'wagmi';
import { materialsAddress, materialsAbi } from './constants';
import { ethers } from 'ethers';

const Mint = ({ address }) => {
	const [rawMaterialId, setRawMaterialId] = useState(0);
	const [currentIndex, setCurrentIndex] = useState(0);
	const [quantity, setQuantity] = useState(1);
	const [value, setValue] = useState(0.005);
	const [userCooldown, setUserCooldown] = useState(0);

	const rawMaterials = ['1. Wood', '2. Stone', '3. Iron', '4. Gold'];
	const images = [wood, stone, iron, gold];

	const {
		data: mintData,
		isLoading: isMintLoading,
		isSuccess: isMintStarted,
		isIdle,
		write: mintRawMaterial,
	} = useContractWrite({
		address: materialsAddress,
		abi: materialsAbi,
		functionName: 'mint',
	});

	const { isSuccess: txCompleted, isFetched: txFetched } =
		useWaitForTransaction({
			hash: mintData?.hash,
		});

	const { data: coolDown, isFetched: coolDownFetched } = useContractRead({
		address: materialsAddress,
		abi: materialsAbi,
		functionName: 'userCooldown',
		args: [address],
	});

	let currTime = new Date();
	let unixTime = Math.floor(currTime.getTime() / 1000);

	const isCooldown =
		parseInt(userCooldown.toString()) + 86400 > unixTime ? true : false;

	console.log(`User Cooldown: `, parseInt(userCooldown?.toString()));
	console.log(`Current Time`, unixTime);
	console.log(`Cooldown ?`, isCooldown);

	const { data: userBalance, isFetched } = useContractReads({
		contracts: [
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 0],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 1],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 2],
			},
			{
				address: materialsAddress,
				abi: materialsAbi,
				functionName: 'balanceOf',
				args: [address, 3],
			},
		],
		onError(error) {
			console.log('Error:', error);
		},
	});

	console.log('User Balance:', userBalance);

	const {
		isLoading: claimLoading,
		isSuccess: claimSuccess,
		write: claim,
	} = useContractWrite({
		address: materialsAddress,
		abi: materialsAbi,
		functionName: 'claimResources',
	});

	const handleQuantityChange = (e) => {
		// set qunatity
		setQuantity(e.target.value);
	};
	const handleValueChange = (e) => {
		setValue(e.target.value) * quantity;
	};

	const moveLeft = () => {
		setCurrentIndex((prevIndex) =>
			prevIndex === 0 ? images.length - 1 : prevIndex - 1
		);
		setRawMaterialId(currentIndex - 1);
	};

	const moveRight = () => {
		setCurrentIndex((prevIndex) =>
			prevIndex === images.length - 1 ? 0 : prevIndex + 1
		);
		setRawMaterialId(currentIndex + 1);
	};

	const isFirstImage = currentIndex === 0;
	const isLastImage = currentIndex === images.length - 1;

	useEffect(() => {
		setUserCooldown(coolDown);
		setRawMaterialId(currentIndex);
		console.log(`Raw Material Id:`, rawMaterialId);
		console.log(`Connected User:`, address);
	}, [address, currentIndex, rawMaterialId, coolDown, isMintLoading]);

	return (
		<div>
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
			<div className='flex flex-col justify-center p-3'>
				<div className='flex justify-center'>
					<input
						type='number'
						id='quantity'
						name='quantity'
						value={quantity}
						onChange={handleQuantityChange}
						className='mr-16 ml-16 text-xl border border-gray-300 rounded  text-gray-800 focus:outline-none focus:ring focus:border-blue-500'
					></input>
				</div>
				<h2
					className='text-xl  text-white text-center pt-2'
					onChange={handleValueChange}
				>
					Total ETH: {value * quantity}
				</h2>
			</div>

			<div className='flex justify-center pt-4'>
				{address ? (
					<button
						id='mintButton'
						className='bg-red-500  rounded py-2 px-4 hover:bg-red-600 text-xl pl-5 pr-5'
						disabled={isMintLoading}
						onClick={() =>
							mintRawMaterial({
								args: [rawMaterialId, quantity],
								from: address,
								value: ethers.parseEther(
									(value * quantity).toString()
								),
							})
						}
					>
						Mint
						{txCompleted &&
							alert(`NFT Minted!!! Tx Hash: ${mintData?.hash}`)}
					</button>
				) : (
					<h1 className='text-red-600 text-xl  font-bold'>
						Please Connect your wallet to Mint 😄
					</h1>
				)}
			</div>
			<div className='flex flex-col justify-center p-3'>
				<div className='flex justify-center'>
					{address && (
						<button
							className='bg-blue-500  text-white px-8 py-2 rounded-md '
							disabled={isCooldown}
							onClick={() => claim()}
						>
							{claimLoading && 'Waiting for approval...'}
							{claimSuccess && 'Claiming...'}
							{!claimLoading &&
								!claimSuccess &&
								'Claim Resources'}
						</button>
					)}
				</div>
				{address && (
					<p className='text-gray-500 text-lg pt-2 text-center'>
						You can claim every 24 hours,
						<br /> You will receive Random Material & Random amount.
					</p>
				)}
			</div>

			{address && userBalance && isFetched && (
				<div className='flex justify-center pt-4'>
					<table className='border-collapse  border-gray-300 '>
						<tHead>
							<tr>
								<th className='text-zinc-400 text-2xl px-5'>
									Raw Materials
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
										{userBalance[index]?.result.toString()}
									</td>
								</tr>
							))}
						</tbody>
					</table>
				</div>
			)}
		</div>
	);
};

export default Mint;
