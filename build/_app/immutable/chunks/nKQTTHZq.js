import{k as o,l as t,u as c,o as i}from"./CpTWrPA6.js";function l(n){{const e=new Error(`lifecycle_outside_component
\`${n}(...)\` can only be used during component initialisation
https://svelte.dev/e/lifecycle_outside_component`);throw e.name="Svelte error",e}}function a(n){o===null&&l("onMount"),t&&o.l!==null?u(o).m.push(n):c(()=>{const e=i(n);if(typeof e=="function")return e})}function u(n){var e=n.l;return e.u??(e.u={a:[],b:[],m:[]})}export{a as o};
