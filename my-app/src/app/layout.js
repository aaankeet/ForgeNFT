import './globals.css';
import '@rainbow-me/rainbowkit/styles.css';
import { Inter } from 'next/font/google';
import { Providers } from './providers.js';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({ children }) {
	return (
		<html lang='en'>
			<body className={inter.className}>
				<Providers>{children}</Providers>
			</body>
		</html>
	);
}
