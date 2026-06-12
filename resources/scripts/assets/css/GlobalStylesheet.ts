import tw from 'twin.macro';
import { createGlobalStyle } from 'styled-components/macro';
export default createGlobalStyle`
    body { ${tw`bg-neutral-800 text-neutral-200`}; background-color: transparent !important; letter-spacing: 0.015em; }
    h1, h2, h3, h4, h5, h6 { ${tw`font-medium tracking-normal font-header`}; }
    p { ${tw`text-neutral-200 leading-snug font-sans`}; }
    form { ${tw`m-0`}; }
    textarea, select, input, button { ${tw`outline-none`}; }
    .fade-enter { opacity: 0; transform: translateY(10px); }
    .fade-enter-active { opacity: 1; transform: translateY(0); transition: all 300ms ease-out; }
    #app { min-height: 100vh; }
`;
