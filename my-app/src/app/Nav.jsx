'use client';
import Link from 'next/link';
import { useState } from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { BsFillMoonStarsFill } from 'react-icons/bs';

function Nav({ address }) {
	return (
		<nav className='py-10 mb-12 flex justify-between pt-5 dark:text-white'>
			<h1 className=' text-2xl font-inter pl-10 font-bold'>ForgeNFT</h1>

			<ul className='flex items-center gap-10'>
				<Link href='/' className='font-bold text-2xl'>
					Home
				</Link>
				<Link
					href='/Assembler'
					className='text-white font-bold text-2xl'
				>
					Assembler
				</Link>
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
