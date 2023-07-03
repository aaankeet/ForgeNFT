'use client';
import Nav from './Nav.jsx';
import Mint from './Mint.jsx';
import { useAccount, useConnect } from 'wagmi';
import { useEffect } from 'react';

export default function Home() {
	const {
		address,
		isConnecting,
		isConnected: connected,
		isDisconnected,
	} = useAccount();

	useEffect(() => {
		if (!address) {
			alert(`Please Connect you Wallet`);
		}
	});
	return (
		<div>
			<main className=''>
				<Nav address={address} />

				<section>
					<h1 className='text-center text-white text-2xl font-bold'>
						Mint Raw Materials and Forge them to build New Items.
					</h1>

					<div className='flex justify-center pt-10'>
						<Mint address={address}></Mint>
					</div>
				</section>
			</main>
		</div>
	);
}
