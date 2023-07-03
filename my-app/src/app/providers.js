'use client';

import * as React from 'react';
import {
	RainbowKitProvider,
	connectorsForWallets,
	darkTheme,
	getDefaultWallets,
	lightTheme,
	midnightTheme,
} from '@rainbow-me/rainbowkit';
import { configureChains, createConfig, WagmiConfig } from 'wagmi';
import { createPublicClient, http } from 'viem';
import { infuraProvider } from 'wagmi/providers/infura';
import { sepolia } from 'wagmi/chains';

const { chains } = configureChains(
	[sepolia],
	[
		infuraProvider({
			apiKey: 'https://sepolia.infura.io/v3/d21c0770599c4e14942b9f3d36ec4357',
		}),
	]
);
const { wallets } = getDefaultWallets({
	appName: 'My RainbowKit App',
	projectId: '345b8d88ebea1ec8fe7c27963b4a1789',
	chains,
});

const connectors = connectorsForWallets([...wallets]);

const wagmiConfig = createConfig({
	autoConnect: true,
	connectors,
	publicClient: createPublicClient({
		chain: sepolia,
		transport: http(),
	}),
});

export function Providers({ children }) {
	const [mounted, setMounted] = React.useState(false);

	React.useEffect(() => setMounted(true), []);
	return (
		<WagmiConfig config={wagmiConfig}>
			<RainbowKitProvider
				theme={lightTheme({
					accentColor: '#0E76FD',
					accentColorForeground: 'white',
					borderRadius: 'small',
					fontStack: 'rounded',
					overlayBlur: 'large',
				})}
				chains={chains}
			>
				{mounted && children}
			</RainbowKitProvider>
		</WagmiConfig>
	);
}
