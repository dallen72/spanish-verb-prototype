<script setup lang="ts">
import type { MatchingCard } from '../lib/types/MatchingCard';

// Define emits
defineEmits<{
  click: []  // empty array means no payload
}>();

// Define props that implement MatchingCard interface
withDefaults(defineProps<MatchingCard>(), {
  isActive: false,
  isMatched: false,
  text: "",
  value: ""
});
</script>

<template>
  <div 
    class="game-card"
    :class="{ 
      active: isActive,
      matched: isMatched 
    }"
    @click="$emit('click')"
  >
    {{ text }}
  </div>
</template>

<style scoped>
.game-card {
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