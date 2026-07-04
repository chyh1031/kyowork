import { useEffect, useState } from 'react';
import { router } from 'expo-router';
import { ActivityIndicator, FlatList, Pressable, StyleSheet, Text, View } from 'react-native';

import { fetchMyListings, LoginRequiredError, type SavedListing } from '@/services/listingService';

type Status = 'loading' | 'needsLogin' | 'error' | 'ready';

const STATUS_LABEL: Record<SavedListing['status'], string> = {
  active: '판매중',
  sold: '판매완료',
  archived: '보관됨',
};

export default function MyPage() {
  const [status, setStatus] = useState<Status>('loading');
  const [listings, setListings] = useState<SavedListing[]>([]);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    fetchMyListings()
      .then((result) => {
        setListings(result);
        setStatus('ready');
      })
      .catch((error) => {
        if (error instanceof LoginRequiredError) {
          setStatus('needsLogin');
        } else {
          setErrorMessage(error instanceof Error ? error.message : '불러오기에 실패했습니다.');
          setStatus('error');
        }
      });
  }, [reloadKey]);

  function retry() {
    setStatus('loading');
    setReloadKey((key) => key + 1);
  }

  if (status === 'loading') {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (status === 'needsLogin') {
    return (
      <View style={styles.center}>
        <Text style={styles.hint}>등록이력을 보려면 로그인해주세요.</Text>
        <Pressable style={styles.button} onPress={() => router.push('/login')}>
          <Text style={styles.buttonText}>로그인하기</Text>
        </Pressable>
      </View>
    );
  }

  if (status === 'error') {
    return (
      <View style={styles.center}>
        <Text style={styles.hint}>{errorMessage}</Text>
        <Pressable style={styles.button} onPress={retry}>
          <Text style={styles.buttonText}>다시 시도</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <FlatList
      contentContainerStyle={styles.container}
      data={listings}
      keyExtractor={(item) => item.id}
      ItemSeparatorComponent={() => <View style={styles.separator} />}
      ListHeaderComponent={<Text style={styles.header}>내가 등록한 물건</Text>}
      ListEmptyComponent={<Text style={styles.hint}>아직 등록한 물건이 없어요.</Text>}
      renderItem={({ item }) => (
        <View style={styles.card}>
          <View style={styles.cardText}>
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.price}>{item.price.toLocaleString('ko-KR')}원</Text>
          </View>
          <Text style={item.status === 'active' ? styles.activeBadge : styles.soldBadge}>
            {STATUS_LABEL[item.status]}
          </Text>
        </View>
      )}
    />
  );
}

const styles = StyleSheet.create({
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    padding: 24,
  },
  container: {
    padding: 24,
    flexGrow: 1,
  },
  header: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 16,
  },
  hint: {
    color: '#555',
    textAlign: 'center',
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
  button: {
    backgroundColor: '#111',
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 999,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
