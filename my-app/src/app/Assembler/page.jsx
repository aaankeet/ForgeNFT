'use client';
import { AiFillLeftCircle, AiFillRightCircle } from 'react-icons/ai';
import { parseEther } from 'viem';
import { useState } from 'react';
import { ethers } from 'ethers';
import Image from 'next/image';
import {
	useContractRead,
	useContractWrite,
	useContractReads,
	useAccount,
	useWaitForTransaction,
} from 'wagmi';
import {
	assemblerAbi,
	assemblerAddress,
	materialsAddress,
	materialsAbi,
} from '../constants';
import { req, rawMaterials, images } from './req';

const Assembler = () => {
	const { address, isConnected } = useAccount();

	const [currentIndex, setCurrentIndex] = useState(0);
	const [itemId, setItemId] = useState(0);
	const [requirements, setRequirements] = useState([2, 0, 1, 0]);

	console.log(requirements);

	const {
		data: approveData,
		write: approve,
		isLoading: isApproveLoading,
	} = useContractWrite({
		address: materialsAddress,
		abi: materialsAbi,
		functionName: 'setApprovalForAll',
		args: [materialsAddress, true],
	});

	console.log(approveData?.hash);
	const {
		data,
		isSuccess: isApproveTxSuccess,
		isLoading: isApproveTxLoading,
	} = useWaitForTransaction({
		chainId: 11155111,
		hash: approveData?.hash,
		enabled: false,
		staleTime: 10_000,
	});

	const { data: isApproved, isFetched: isApprovedFetched } = useContractRead({
		address: materialsAddress,
		abi: materialsAbi,
		functionName: 'isApprovedForAll',
		args: [address, materialsAddress],
	});

	console.log(isApproved);

	const {
		write: forge,
		isSuccess: isForgeSuccess,
		isLoading: isForgeLoading,
	} = useContractWrite({
		address: assemblerAddress,
		abi: assemblerAbi,
		functionName: 'forge',
		args: [currentIndex + 4],
		value: parseEther('0.05'),
		// gas: 300_000n,
	});
	console.log(`Current Id: ${currentIndex + 4}`);

	const { data: cost, isFetched } = useContractRead({
		address: assemblerAddress,
		abi: assemblerAbi,
		functionName: 'FORGE_COST',
	});

	const { data: userBalance, isFetched: balanceFetched } = useContractReads({
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

	const moveLeft = () => {
		setCurrentIndex((prevIndex) =>
			prevIndex === 0 ? images.length - 1 : prevIndex - 1
		);
		setItemId(currentIndex - 1);
		setRequirements(req[currentIndex - 1]);
	};
	const moveRight = () => {
		setCurrentIndex((prevIndex) =>
			prevIndex === images.length - 1 ? 0 : prevIndex + 1
		);
		setItemId(currentIndex + 1);
		setRequirements(req[currentIndex + 1]);
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

			<div>
				{address ? (
					<div>
						<div className='flex justify-center'>
							{!isApproved && (
								<button
									id='approve-btn'
									disabled={
										isApproveLoading || isApproveTxLoading
									}
									className='bg-red-500 rounded px-2 py-3 '
									onClick={() => {
										approve();
									}}
								>
									{isApproveLoading || isApproveTxLoading
										? 'Approving...'
										: 'Approve'}
								</button>
							)}
						</div>

						<div className='flex items-center justify-center flex-col'>
							{isApproved && (
								<button
									disabled={isForgeLoading}
									className='bg-blue-600 rounded px-3 py-2.5 '
									onClick={() => forge({})}
								>
									{isForgeLoading && 'Forging...'}
									{!isForgeLoading && 'Forge'}
								</button>
							)}
							<h1 className='text-white text-center text-xl font-bold py-3'>
								Forge Cost:
								{ethers.formatEther(cost?.toString(), 18)} ETH
							</h1>
						</div>

						{!isApproved && (
							<p className='text-red-400 text-center text-xl font-bold py-3'>
								You need to approve the Assembler to forge your
								materials. <br />
							</p>
						)}

						<div>
							{userBalance && balanceFetched && (
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
												<th className='text-zinc-400 text-2xl  px-5'>
													Requirements
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
														].result?.toString()}
													</td>
													<td className='text-gray-500 text-xl px-24'>
														{requirements[index]}
													</td>
												</tr>
											))}
										</tbody>
									</table>
								</div>
							)}
						</div>
					</div>
				) : (
					<h1 className='text-red-500 text-center text-xl font-bold py-3'>
						Please Connect to the Wallet to forge your materials
					</h1>
				)}
			</div>
		</div>
	);
};
export default Assembler;
