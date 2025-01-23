<script lang="ts">
    export let isActive: boolean = false;
    export let isMatched: boolean = false;
    export let text: string = "";
    export const value: string = "";
</script>

<div 
    class="card"
    class:active={isActive}
    class:matched={isMatched}
>
    {text}
</div>

<style>
    .card {
        cursor: pointer;
        background-color: #4a90e2;
        color: white;
        border-radius: 8px;
        transition: background-color 0.3s ease;
        padding: 1rem 2rem;
        font-size: 1.2rem;
        display: flex;
        justify-content: center;
        align-items: center;
        user-select: none;
    }

    .active {
        background-color: #f39c12;
    }

    .matched {
        background-color: #27ae60;
        cursor: default;
    }
</style> 