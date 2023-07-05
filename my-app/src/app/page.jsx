'use client';

import Mint from './Mint.jsx';
import Head from 'next/head';
import { AiFillGithub } from 'react-icons/ai';
import { useAccount } from 'wagmi';

export default function Home() {
	const { address, isConnected: connected } = useAccount();

	return (
		<div>
			<Head>
				<title>Home</title>
			</Head>

			<main className=''>
				<section>
					<h1
						className='text-center text-5xl font-bold
					 bg-gradient-to-r from-yellow-200 to-pink-300 via-orange-200 
					 text-transparent bg-clip-text py-2'
					>
						Mint Raw Materials and Forge them to Build New Items.
					</h1>

					<div className='flex justify-center pt-10'>
						{!address && (
							<h1 className='text-red-600 text-4xl font-extralight'>
								Please Connect your Wallet First 🙂
							</h1>
						)}
						{address && <Mint address={address}></Mint>}
					</div>
				</section>
				<div>
					<a
						href='https://github.com/aaankeet/ForgeNFT'
						target='_blank'
						rel='noopener noreferrer'
						class='fixed bottom-4 right-4 pr-10 pb-6'
					>
						<AiFillGithub className='text-5xl text-gray-500 hover:text-zinc-300' />
						<br />
					</a>
					<a
						href='https://github.com/aaankeet/ForgeNFT'
						target='_blank'
						rel='noopener noreferrer'
						class='fixed bottom-8 right-8  text-zinc-300 font-light'
					>
						Source Code
					</a>
				</div>
			</main>
		</div>
	);
}
