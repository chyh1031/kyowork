import { forwardRef } from 'react';
import { StyleSheet, Text, View } from 'react-native';

import type { Listing } from '@/schemas/listing';

type Props = {
  listing: Listing;
};

const ShareCard = forwardRef<View, Props>(({ listing }, ref) => {
  return (
    <View ref={ref} collapsable={false} style={styles.card}>
      <Text style={styles.title}>{listing.title}</Text>
      <Text style={styles.description} numberOfLines={4}>
        {listing.description}
      </Text>
      <Text style={styles.price}>{listing.price.toLocaleString('ko-KR')}원</Text>
      <Text style={styles.watermark}>MiddlePoint</Text>
    </View>
  );
});

ShareCard.displayName = 'ShareCard';

export default ShareCard;

const styles = StyleSheet.create({
  card: {
    width: 320,
    padding: 24,
    gap: 12,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
  },
  description: {
    fontSize: 14,
    color: '#555',
  },
  price: {
    fontSize: 24,
    fontWeight: '800',
  },
  watermark: {
    marginTop: 16,
    fontSize: 12,
    color: '#999',
    textAlign: 'right',
  },
});
