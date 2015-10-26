/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
	@defgroup cpSpatialIndex cpSpatialIndex

	Spatial indexes are data structures that are used to accelerate collision detection
	and spatial queries. Chipmunk provides a number of spatial index algorithms to pick from
	and they are programmed in a generic way so that you can use them for holding more than
	just cpShape structs.

	It works by using @c void pointers to the objects you add and using a callback to ask your code
	for bounding boxes when it needs them. Several types of queries can be performed an index as well
	as reindexing and full collision information. All communication to the spatial indexes is performed
	through callback functions.

	Spatial indexes should be treated as opaque structs.
	This meanns you shouldn't be reading any of the struct fields.
	@{
*/

//MARK: Spatial Index

/// Spatial index bounding box callback function type.
/// The spatial index calls this function and passes you a pointer to an object you added
/// when it needs to get the bounding box associated with that object.
typedef cpBB (*cpSpatialIndexBBFunc)(void *obj);
/// Spatial index/object iterator callback function type.
typedef void (*cpSpatialIndexIteratorFunc)(void *obj, void *data);
/// Spatial query callback function type.
typedef cpCollisionID (*cpSpatialIndexQueryFunc)(void *obj1, void *obj2, cpCollisionID id, void *data);
/// Spatial segment query callback function type.
typedef cpFloat (*cpSpatialIndexSegmentQueryFunc)(void *obj1, void *obj2, void *data);


typedef struct cpSpatialIndexClass cpSpatialIndexClass;
typedef struct cpSpatialIndex cpSpatialIndex;

/// @private
/* struct cpSpatialIndex { */
/* 	cpSpatialIndexClass *klass; */

/* 	cpSpatialIndexBBFunc bbfunc; */

/* 	cpSpatialIndex *staticIndex, *dynamicIndex; */
/* }; */


//MARK: Spatial Hash

typedef struct cpSpaceHash cpSpaceHash;

/// Allocate a spatial hash.
cpSpaceHash* cpSpaceHashAlloc(void)
{};
