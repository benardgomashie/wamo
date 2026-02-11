'use client';

import { useState } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency, formatDateTime, getStatusColor } from '@/lib/utils';
import { Search as SearchIcon } from 'lucide-react';
import type { Campaign } from '@/types/campaign';
import Link from 'next/link';

export default function SearchPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [searchType, setSearchType] = useState<'id' | 'phone' | 'name'>('id');
  const [results, setResults] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);

  const handleSearch = async () => {
    if (!searchTerm.trim()) return;

    setLoading(true);
    setSearched(true);
    
    try {
      let q;
      
      switch (searchType) {
        case 'id':
          // Search by campaign ID
          const campaignDoc = await getDocs(
            query(collection(db, 'campaigns'), where('__name__', '==', searchTerm.trim()))
          );
          setResults(campaignDoc.docs.map(doc => ({ id: doc.id, ...doc.data() } as Campaign)));
          break;
          
        case 'phone':
          // Search by phone number in verification data
          q = query(
            collection(db, 'campaigns'),
            where('verification.phoneNumber', '==', searchTerm.trim())
          );
          const phoneResults = await getDocs(q);
          setResults(phoneResults.docs.map(doc => ({ id: doc.id, ...doc.data() } as Campaign)));
          break;
          
        case 'name':
          // Search campaigns and filter by creator name (client-side filtering)
          const allCampaigns = await getDocs(collection(db, 'campaigns'));
          const filtered = allCampaigns.docs
            .map(doc => ({ id: doc.id, ...doc.data() } as Campaign))
            .filter(campaign => {
              const term = searchTerm.toLowerCase();
              const title = campaign.title?.toLowerCase() || '';
              const creatorName = campaign.verification?.fullName?.toLowerCase() || '';
              return title.includes(term) || creatorName.includes(term);
            });
          setResults(filtered);
          break;
      }
    } catch (error) {
      console.error('Search error:', error);
      alert('Search failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Search</h1>
        <p className="mt-2 text-gray-600">Find campaigns by ID, phone number, or name</p>
      </div>

      {/* Search Form */}
      <Card>
        <CardContent className="p-6">
          <div className="flex gap-4">
            <select
              value={searchType}
              onChange={(e) => setSearchType(e.target.value as any)}
              className="border border-gray-300 rounded-lg px-4 py-2 text-sm"
            >
              <option value="id">Campaign ID</option>
              <option value="phone">Phone Number</option>
              <option value="name">Name / Title</option>
            </select>

            <div className="flex-1 relative">
              <input
                type="text"
                placeholder={
                  searchType === 'id' ? 'Enter campaign ID...' :
                  searchType === 'phone' ? 'Enter phone number...' :
                  'Enter creator name or campaign title...'
                }
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                className="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm"
              />
            </div>

            <Button
              variant="primary"
              onClick={handleSearch}
              disabled={loading || !searchTerm.trim()}
            >
              <SearchIcon className="h-4 w-4 mr-2" />
              Search
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Results */}
      {loading ? (
        <div className="text-center py-12">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
          <p className="mt-4 text-gray-600">Searching...</p>
        </div>
      ) : searched && results.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-gray-600">No campaigns found</p>
          </CardContent>
        </Card>
      ) : results.length > 0 ? (
        <div className="space-y-4">
          <h2 className="text-lg font-semibold text-gray-900">
            {results.length} {results.length === 1 ? 'result' : 'results'} found
          </h2>
          
          {results.map((campaign) => (
            <Card key={campaign.id}>
              <CardContent className="p-6">
                <div className="flex gap-4">
                  {campaign.proofUrls?.[0] && (
                    <img
                      src={campaign.proofUrls[0]}
                      alt={campaign.title}
                      className="w-24 h-24 rounded-lg object-cover"
                    />
                  )}
                  
                  <div className="flex-1">
                    <div className="flex items-start justify-between">
                      <div>
                        <h3 className="text-lg font-semibold text-gray-900">
                          {campaign.title}
                        </h3>
                        <div className="mt-1 flex items-center gap-2">
                          <Badge className={getStatusColor(campaign.status)}>
                            {campaign.status}
                          </Badge>
                          <span className="text-sm text-gray-500">
                            {campaign.cause}
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className="mt-4 grid grid-cols-4 gap-4 text-sm">
                      <div>
                        <span className="text-gray-500">ID:</span>
                        <span className="ml-2 font-mono">{campaign.id.slice(0, 12)}...</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Target:</span>
                        <span className="ml-2 font-semibold">
                          {formatCurrency(campaign.targetAmount)}
                        </span>
                      </div>
                      <div>
                        <span className="text-gray-500">Raised:</span>
                        <span className="ml-2 font-semibold">
                          {formatCurrency(campaign.raisedAmount || 0)}
                        </span>
                      </div>
                      <div>
                        <span className="text-gray-500">Created:</span>
                        <span className="ml-2">{formatDateTime(campaign.createdAt)}</span>
                      </div>
                    </div>

                    <div className="mt-4">
                      <Link href={`/dashboard/campaigns?id=${campaign.id}`}>
                        <Button variant="outline" size="sm">
                          View in Campaigns
                        </Button>
                      </Link>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : null}
    </div>
  );
}
