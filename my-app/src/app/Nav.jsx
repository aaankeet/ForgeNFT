'use client';
import Link from 'next/link';
import { useState } from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { BsFillMoonStarsFill } from 'react-icons/bs';
import { useContractWrite } from 'wagmi';
import { materialsAddress, materialsAbi } from './constants';

function Nav({ address }) {
	const [darkmode, setDarkmode] = useState(false);

	const { data, write: claim } = useContractWrite({
		address: materialsAddress,
		abi: materialsAbi,
		functionName: 'claimResources',
	});

	return (
		<nav className='py-10 mb-12 flex justify-between pt-5 dark:text-white'>
			<h1 className='text-2xl font-inter pl-10 font-bold'>ForgeNFT</h1>
			{address && (
				<button
					className='bg-blue-500  text-white px-8 py-2 rounded-md mr-40'
					onClick={() => claim()}
				>
					Claim Materials
				</button>
			)}
			<Link href='/Assembler' className='text-2xl font-bold'>
				Assembler
			</Link>
			<ul className='flex items-center gap-10'>
				<li className='cursor-pointer text-2xl'>
					<BsFillMoonStarsFill
						onClick={() => setDarkmode(!darkmode)}
					/>
				</li>
				<li className='pr-5'>
					<ConnectButton />
				</li>
			</ul>
		</nav>
	);
}

export default Nav;
