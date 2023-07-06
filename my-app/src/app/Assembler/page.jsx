import { useContractWrite } from 'wagmi';
import { assemblerAbi, assemblerAddress } from '../constants';

export default function Assembler() {
	const {
		write: forge,
		isSuccess,
		isLoading,
	} = useContractWrite({
		address: assemblerAddress,
		abi: assemblerAbi,
		functionName: 'forge',
	});

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
		</div>
	);
}
