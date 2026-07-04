import { FlatList, StyleSheet, Text, View } from 'react-native';

type DummyListing = {
  id: string;
  title: string;
  price: number;
  status: 'active' | 'sold';
};

// TODO(S3 이후): Supabase listings 테이블 연동으로 교체. 지금은 정적 목업.
const DUMMY_LISTINGS: DummyListing[] = [
  { id: '1', title: '아이폰 13 프로 256GB 그래파이트', price: 650000, status: 'active' },
  { id: '2', title: '이케아 린몬 책상', price: 45000, status: 'sold' },
  { id: '3', title: '다이슨 무선 청소기 V8', price: 120000, status: 'active' },
];

export default function MyPage() {
  return (
    <FlatList
      contentContainerStyle={styles.container}
      data={DUMMY_LISTINGS}
      keyExtractor={(item) => item.id}
      ItemSeparatorComponent={() => <View style={styles.separator} />}
      ListHeaderComponent={<Text style={styles.header}>내가 등록한 물건</Text>}
      renderItem={({ item }) => (
        <View style={styles.card}>
          <View style={styles.cardText}>
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.price}>{item.price.toLocaleString('ko-KR')}원</Text>
          </View>
          <Text style={item.status === 'sold' ? styles.soldBadge : styles.activeBadge}>
            {item.status === 'sold' ? '판매완료' : '판매중'}
          </Text>
        </View>
      )}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 24,
  },
  header: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 16,
  },
  separator: {
    height: 12,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    borderRadius: 12,
    backgroundColor: '#f4f4f4',
  },
  cardText: {
    gap: 4,
  },
  title: {
    fontSize: 15,
    fontWeight: '600',
  },
  price: {
    fontSize: 13,
    color: '#555',
  },
  activeBadge: {
    fontSize: 12,
    fontWeight: '600',
    color: '#0a7d33',
  },
  soldBadge: {
    fontSize: 12,
    fontWeight: '600',
    color: '#999',
  },
});
