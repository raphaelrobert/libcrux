use std::ops::{self, Index, IndexMut};

use crate::field::FieldElement;

pub trait Bits<F: FieldElement, const COEFFICIENTS: usize> {
    fn bit(&self, bit: usize) -> u8;
    fn bits_iter(&self) -> BitsIter<'_, F, COEFFICIENTS>;
    fn bits_chunks(&self, chunk_len: usize) -> BitsIter<'_, F, COEFFICIENTS>;
}

pub struct BitsIter<'a, F: FieldElement, const COEFFICIENTS: usize> {
    values: &'a [F; COEFFICIENTS],
    bit: usize,
    chunk_len: usize,
}

impl<F: FieldElement, const COEFFICIENTS: usize> Bits<F, COEFFICIENTS> for &[F; COEFFICIENTS] {
    fn bit(&self, bit: usize) -> u8 {
        let index = bit / 16;
        let bit_mod = bit % 16;
        // eprintln!(" >>> self[{index}] >> {bit_mod}");
        ((Into::<u16>::into(self[index]) >> bit_mod) & 1) as u8
    }

    fn bits_iter(&self) -> BitsIter<'_, F, COEFFICIENTS> {
        BitsIter {
            values: self,
            bit: 0,
            chunk_len: 1,
        }
    }

    fn bits_chunks(&self, chunk_len: usize) -> BitsIter<'_, F, COEFFICIENTS> {
        // This iterator allows setting the number of bits used to encode one limb.
        // It is NOT chunking.
        assert!(chunk_len <= 16);
        BitsIter {
            values: self,
            bit: 0,
            chunk_len,
        }
    }
}

impl<F: FieldElement, const COEFFICIENTS: usize> Iterator for BitsIter<'_, F, COEFFICIENTS> {
    type Item = Vec<u8>;

    fn next(&mut self) -> Option<Self::Item> {
        let byte_index = (self.bit + self.chunk_len) / 16;
        if byte_index >= self.values.len() {
            return None;
        }

        let mut out = vec![0u8; self.chunk_len];
        // eprintln!(
        //     " >>> bits: {}-{} ({})",
        //     self.bit,
        //     self.bit + self.chunk_len,
        //     self.bit / 16
        // );
        for i in 0..self.chunk_len {
            out[i] = self.values.bit(self.bit + i);
        }
        self.bit += 16;

        Some(out)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PolynomialRingElement<F: FieldElement, const COEFFICIENTS: usize> {
    pub(crate) coefficients: [F; COEFFICIENTS],
}

impl<F: FieldElement, const COEFFICIENTS: usize> PolynomialRingElement<F, COEFFICIENTS> {
    pub const ZERO: Self = Self {
        coefficients: [F::ZERO; COEFFICIENTS],
    };

    pub fn new(coefficients: [F; COEFFICIENTS]) -> Self {
        Self { coefficients }
    }

    pub fn coefficients(&self) -> &[F; COEFFICIENTS] {
        &self.coefficients
    }

    pub fn len(&self) -> usize {
        self.coefficients.len()
    }
}

impl<F: FieldElement, const COEFFICIENTS: usize> Index<usize>
    for PolynomialRingElement<F, COEFFICIENTS>
{
    type Output = F;

    fn index(&self, index: usize) -> &Self::Output {
        &self.coefficients[index]
    }
}

impl<F: FieldElement, const COEFFICIENTS: usize> IndexMut<usize>
    for PolynomialRingElement<F, COEFFICIENTS>
{
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        &mut self.coefficients[index]
    }
}

impl<F: FieldElement, const COEFFICIENTS: usize> IntoIterator
    for PolynomialRingElement<F, COEFFICIENTS>
{
    type Item = F;

    type IntoIter = std::array::IntoIter<F, COEFFICIENTS>;

    fn into_iter(self) -> Self::IntoIter {
        self.coefficients.into_iter()
    }
}

impl<F: FieldElement, const COEFFICIENTS: usize> ops::Add
    for PolynomialRingElement<F, COEFFICIENTS>
{
    type Output = Self;

    fn add(self, other: Self) -> Self {
        let mut result = PolynomialRingElement::<F, COEFFICIENTS>::ZERO;
        for i in 0..self.coefficients.len() {
            result.coefficients[i] = self.coefficients[i] + other.coefficients[i];
        }
        result
    }
}
impl<F: FieldElement, const COEFFICIENTS: usize> ops::Sub
    for PolynomialRingElement<F, COEFFICIENTS>
{
    type Output = Self;

    fn sub(self, other: Self) -> Self {
        let mut result = PolynomialRingElement::<F, COEFFICIENTS>::ZERO;
        for i in 0..self.coefficients.len() {
            result.coefficients[i] = self.coefficients[i] - other.coefficients[i];
        }
        result
    }
}
