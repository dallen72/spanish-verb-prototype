import { describe, it, expect } from 'vitest'

import { mount } from '@vue/test-utils'
import CardMatching from '../../components/CardMatching.vue'

describe('CardMatching', () => {
  it('renders properly', () => {
    const wrapper = mount(CardMatching)
    //expect cardmatching to contain 7 cards
    expect(wrapper.findAll('.game-card').length).toBe(7)
  })
})
